//
// Created by Martin Weißbach on 10/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import <MobilisMXi/MXi/MXiMultiUserChatRoom.h>
#import <MobilisMXi/MXi/MXiMultiUserChatDiscovery.h>
#import "ServerComponent.h"
#import "MXiConnectionHandler.h"
#import "RegisterPublisher.h"
#import "RegisterReceiver.h"
#import "CreateSensorMUCDomain.h"
#import "RemovePublisher.h"
#import "RemoveReceiver.h"
#import "PubSubStore.h"
#import "MUCDiscovery.h"
#import "ACDSMultiUserChatRoom.h"
#import "DomainStore.h"
#import "GetSensorMUCDomainsRequest.h"
#import "SensorMUCDomainRemoved.h"
#import "SensorMUCDomainCreated.h"
#import "SensorItem.h"
#import "DelegateSensorItemsOut.h"


@interface DiscoveryMapping : NSObject

@property (nonatomic) CreateSensorMUCDomain *domain;
@property (nonatomic) MXiMultiUserChatDiscovery *discovery;

- (id)initWithDomain:(CreateSensorMUCDomain *)domain discovery:(MXiMultiUserChatDiscovery *)discovery;

@end

@implementation DiscoveryMapping

- (id)initWithDomain:(CreateSensorMUCDomain *)domain discovery:(MXiMultiUserChatDiscovery *)discovery
{
    self = [super init];
    if (self) {
        self.domain = domain;
        self.discovery = discovery;
    }
    return self;
}

@end

@interface ServerComponent () <MXiMultiUserChatDelegate, MXiMultiUserChatDiscoveryDelegate>

@property NSMutableArray *discoveredMUCRooms;
@property DomainStore *domainStore;

@property NSMutableArray *runningDiscoveries;

@end

@implementation ServerComponent

- (void)setupService
{
    self.discoveredMUCRooms = [NSMutableArray arrayWithCapacity:10];
    self.domainStore = [DomainStore new];

    self.runningDiscoveries = [NSMutableArray arrayWithCapacity:3];

    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self withSelector:@selector(registerPublisher:) forBeanClass:[RegisterPublisher class]];
    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self withSelector:@selector(registerReceiver:) forBeanClass:[RegisterReceiver class]];
    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self withSelector:@selector(removePublisher:) forBeanClass:[RemovePublisher class]];
    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self withSelector:@selector(removeReceiver:) forBeanClass:[RemoveReceiver class]];
    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self withSelector:@selector(createMUCDomain:) forBeanClass:[CreateSensorMUCDomain class]];
    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self withSelector:@selector(removeMUCDomain:) forBeanClass:[SensorMUCDomainRemoved class]];
    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self withSelector:@selector(returnMUCDomains:) forBeanClass:[GetSensorMUCDomainsRequest class]];

    [[MXiConnectionHandler sharedInstance].connection addStanzaDelegate:self withSelector:@selector(iqStanzaReceived:) forStanzaElement:IQ];
}

#pragma mark - Incoming Bean Handler

- (void)removeReceiver:(RemoveReceiver *)removeReceiver
{
    [[PubSubStore sharedInstance] removeReceiver:[removeReceiver from]];
}

- (void)removePublisher:(RemovePublisher *)removePublisher
{
    [[PubSubStore sharedInstance] removePublisher:[removePublisher from]];
}

- (void)registerReceiver:(RegisterReceiver *)registerReceiver
{
    [[PubSubStore sharedInstance] addReceiver:[registerReceiver from]];
}

- (void)registerPublisher:(RegisterPublisher *)registerPublisher
{
    [[PubSubStore sharedInstance] addPublisher:[registerPublisher from]];
}

- (void)createMUCDomain:(CreateSensorMUCDomain *)domain
{
    MXiMultiUserChatDiscovery *chatDiscovery = [MXiMultiUserChatDiscovery multiUserChatDiscoveryWithDomainName:domain.sensorDomain.domainURL
                                                                                                   andDelegate:self];
    [chatDiscovery startDiscoveryWithResultQueue:NULL];
    [self.runningDiscoveries addObject:[[DiscoveryMapping alloc] initWithDomain:domain
                                                                      discovery:chatDiscovery]];
}

- (void)removeMUCDomain:(SensorMUCDomainRemoved *)domain
{
    [self.domainStore removeDomain:domain.sensorDomain];
}

#pragma mark - MXiMultiUserChatDelegate

- (void)connectionToRoomEstablished:(NSString *)roomJID usingRoomJID:(NSString *)myRoomJID
{
    NSLog(@"Connection to roomJID %@ successfully established.\nAlias JID; %@", roomJID, myRoomJID);
}

- (void)didReceiveMultiUserChatMessage:(NSString *)message fromUser:(NSString *)user publishedInRoom:(NSString *)roomJID
{
    NSLog(@"Message: %@ from user %@ in room %@ received.", message, user, roomJID);
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0 
                                                      error:&error];
    if (error || ![jsonObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Message %@ could not be parsed.", message);
        return;
    }

    NSDictionary *sensorEvent = [jsonObject objectForKey:@"sensorevent"];
    
    ACDSMultiUserChatRoom *chatRoom = [self findRoomForJID:roomJID];
    NSString *domainName = [[[[XMPPJID jidWithString:roomJID] domain] componentsSeparatedByString:@"."] lastObject];
    SensorMUCDomain *sensorMUCDomain = [self.domainStore domainForJID:domainName];
    
    SensorItem *sensorItem = [SensorItem new];
    sensorItem.type = [sensorEvent valueForKey:@"type"];
    sensorItem.location = chatRoom.sensorLocation;
    sensorItem.sensorDomain = sensorMUCDomain;

    sensorItem.values = [NSMutableArray arrayWithCapacity:3];
    id <NSFastEnumeration> sensorValues = [sensorEvent valueForKey:@"values"];
    for (NSNumber *rawValue in sensorValues) {
        SensorValue *sensorValue = [SensorValue new];
        sensorValue.value = [rawValue stringValue];
        sensorValue.timestamp = [self timestampFromString:[sensorEvent valueForKey:@"timestamp"]];
        sensorValue.unit = @"Unit";
        [sensorItem.values addObject:sensorValue];
    }

    DelegateSensorItemsOut *delegateSensorItems = [DelegateSensorItemsOut new];
    delegateSensorItems.sensorItems = [NSMutableArray arrayWithObject:sensorItem];

    for (XMPPJID *receiver in [[PubSubStore sharedInstance] receivers]) {
        delegateSensorItems.to = receiver;
        [[MXiConnectionHandler sharedInstance] sendElement:[MXiBeanConverter beanToIQ:delegateSensorItems]];
    }
}

- (Timestamp *)timestampFromString:(NSString *)timestampString
{
    //  2013-09-18T18:31:38+1:00
    NSArray *dateAndTime = [timestampString componentsSeparatedByString:@"T"];
    if (dateAndTime.count != 2)
        return nil;

    Timestamp *timestamp = [Timestamp new];
    [self extractDate:(NSString *)dateAndTime[0] toTimestamp:&timestamp];
    [self extractTime:dateAndTime[1] toTimestamp:&timestamp];

    return timestamp;
}

- (void)extractTime:(NSString *)timeString toTimestamp:(Timestamp **)timestamp
{
    //  18:31:38+01:00
    NSArray *timeComponents = [((NSString *)[timeString componentsSeparatedByString:@"+"][0]) componentsSeparatedByString:@":"];
    if (timeComponents.count != 3)
        return;

    [*timestamp setHour:[timeComponents[0] integerValue]];
    [*timestamp setMinute:[timeComponents[1] integerValue]];
    [*timestamp setSecond:[timeComponents[2] integerValue]];
}

- (void)extractDate:(NSString *)dateString toTimestamp:(Timestamp **)timestamp
{
    //  2013-09-18
    NSArray *dateComponents = [dateString componentsSeparatedByString:@"-"];
    if (dateComponents.count != 3)
        return;

    [*timestamp setYear:[dateComponents[0] integerValue]];
    [*timestamp setMonth:[dateComponents[1] integerValue]];
    [*timestamp setDay:[dateComponents[2] integerValue]];
}

- (ACDSMultiUserChatRoom *)findRoomForJID:(NSString *)jid
{
    ACDSMultiUserChatRoom *multiUserChatRoom = nil;
    for (ACDSMultiUserChatRoom *storedRoom in self.discoveredMUCRooms) {
        if ([[storedRoom.jabberID full] isEqualToString:jid]) {
            multiUserChatRoom = storedRoom;
            break;
        }
    }

    return multiUserChatRoom;
}

#pragma mark - MXiMultiUserChatDiscoveryDelegate

- (void)multiUserChatRoomsDiscovered:(NSArray *)chatRooms inDomain:(NSString *)domainName
{
    CreateSensorMUCDomain *domain = nil;
    for (DiscoveryMapping *mapping in self.runningDiscoveries)
        if ([mapping.domain.sensorDomain.domainURL isEqualToString:domainName]) {
            domain = mapping.domain;
            [self.runningDiscoveries removeObject:mapping];
            break;
        }

    for (MXiMultiUserChatRoom *room in chatRooms) {
        [[MUCDiscovery alloc] initWithRoom:room
                           completionBlock:^(BOOL b, ACDSMultiUserChatRoom *sensorMUC)
                           {
                            if (b) {
                                 [self.discoveredMUCRooms addObject:sensorMUC];
                                 [[MXiConnectionHandler sharedInstance].connection connectToMultiUserChatRoom:[sensorMUC.jabberID full]
                                                                                                 withDelegate:self];
                            }
                           }];
    }
    SensorMUCDomainCreated *domainCreatedBean = [SensorMUCDomainCreated new];
    domainCreatedBean.to = domain.from;
    domainCreatedBean.sensorDomain = domain.sensorDomain;
    [[MXiConnectionHandler sharedInstance] sendElement:[MXiBeanConverter beanToIQ:domainCreatedBean]];
}


@end
