//
// Created by Martin Weißbach on 10/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import <MobilisMXi/MXi/MXiMultiUserChatRoom.h>
#import "ServerComponent.h"
#import "MXiConnectionHandler.h"
#import "RegisterPublisher.h"
#import "RegisterReceiver.h"
#import "CreateSensorMUCDomain.h"
#import "RemovePublisher.h"
#import "RemoveReceiver.h"
#import "PubSubStore.h"
#import "SynchronizeRuntimeBean.h"
#import "MUCDiscovery.h"
#import "ACDSMultiUserChatRoom.h"
#import "DomainStore.h"
#import "GetSensorMUCDomainsRequest.h"
#import "SensorMUCDomainRemoved.h"
#import "SensorMUCDomainCreated.h"
#import "SensorItem.h"
#import "DelegateSensorItemsOut.h"

@interface ServerComponent () <MXiMultiUserChatDelegate>

@property (strong) NSMutableArray *discoveredMUCRooms;
@property (strong) DomainStore *domainStore;

@end

@implementation ServerComponent

+ (instancetype)sharedInstance
{

    static dispatch_once_t once;
    static ServerComponent *shared = nil;
    dispatch_once(&once, ^
    {
        shared = [[self alloc] initUniqueInstance];
    });

    return shared;
}

- (id)initUniqueInstance
{
    self.discoveredMUCRooms = [NSMutableArray arrayWithCapacity:10];
    self.domainStore = [DomainStore new];

    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(registerPublisher:) forBeanClass:[RegisterPublisher class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(registerReceiver:) forBeanClass:[RegisterReceiver class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(removePublisher:) forBeanClass:[RemovePublisher class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(removeReceiver:) forBeanClass:[RemoveReceiver class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(createMUCDomain:) forBeanClass:[CreateSensorMUCDomain class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(removeMUCDomain:) forBeanClass:[SensorMUCDomainRemoved class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(returnMUCDomains:) forBeanClass:[GetSensorMUCDomainsRequest class]];

    [[MXiConnectionHandler sharedInstance] addStanzaDelegate:self];

    return [super init];
}

- (void)synchronizeRuntimes
{
    SynchronizeRuntimeBean *synchronizeRuntimeBean = [[SynchronizeRuntimeBean alloc] initWithTargetRuntimeJID:@"mobilis@localhost/Deployment"];
    [synchronizeRuntimeBean setServiceJIDs:@[@"testserviceacds@localhost"]];

    [[MXiConnectionHandler sharedInstance] sendElement:[MXiBeanConverter beanToIQ:synchronizeRuntimeBean]];
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
    [[MXiConnectionHandler sharedInstance] discoverMultiUserChatRoomsInDomain:domain.sensorDomain.domainURL
                                                          withCompletionBlock:^(BOOL serviceSupported, NSArray *discoveredRooms)
                                                          {
                                                              if (serviceSupported) {
                                                                  [self.domainStore addDomain:domain.sensorDomain];
                                                                  for (MXiMultiUserChatRoom *room in discoveredRooms) {
                                                                      MUCDiscovery *discovery = [[MUCDiscovery alloc] initWithRoom:room
                                                                                                                   completionBlock:^(BOOL b, ACDSMultiUserChatRoom *sensorMUC)
                                                                                                                   {
                                                                                                                       if (b) {
                                                                                                                           [self.discoveredMUCRooms addObject:sensorMUC];
                                                                                                                           [[MXiConnectionHandler sharedInstance] connectToMultiUserChatRoom:[sensorMUC.jabberID full]
                                                                                                                                                                                withDelegate:self];
                                                                                                                       }
                                                                                                                   }];
                                                                  }
                                                                  SensorMUCDomainCreated *domainCreatedBean = [SensorMUCDomainCreated new];
                                                                  domainCreatedBean.to = domain.from;
                                                                  domainCreatedBean.sensorDomain = domain.sensorDomain;
                                                                  [[MXiConnectionHandler sharedInstance] sendElement:[MXiBeanConverter beanToIQ:domainCreatedBean]];
                                                              }
                                                          }];
}

- (void)removeMUCDomain:(SensorMUCDomainRemoved *)domain
{
    [self.domainStore removeDomain:domain.sensorDomain];
}

#pragma mark - MXiConnectionHandler stanza delegate callback

- (void)iqStanzaReceived:(XMPPIQ *)xmppiq
{
    if (    [xmppiq isGetIQ] &&
            [[xmppiq childElement] namespaces].count > 0 &&
            [[[[xmppiq childElement] namespaces][0] stringValue] isEqualToString:@"http://jabber.org/protocol/disco#info"]
            ) {
        NSXMLElement *resultIQBody = [[NSXMLElement alloc] initWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"];

        NSXMLElement *serviceFeatureString = [[NSXMLElement alloc] initWithName:@"feature"];
        [serviceFeatureString addAttributeWithName:@"var" stringValue:[self buildServiceFeatureString]];
        NSXMLElement *serviceInstanceFeatureString = [[NSXMLElement alloc] initWithName:@"feature"];
        [serviceInstanceFeatureString addAttributeWithName:@"var" stringValue:[self buildServiceInstanceFeatureString]];

//        [resultIQBody addChild:serviceFeatureString]; // obviously not required for SINGLE-services
        [resultIQBody addChild:serviceInstanceFeatureString];

        XMPPIQ *responseIQ = [XMPPIQ iqWithType:@"result"
                                             to:[xmppiq from]
                                      elementID:[xmppiq elementID]
                                          child:resultIQBody];
        [[MXiConnectionHandler sharedInstance] sendElement:responseIQ];
    }
}

- (NSString *)buildServiceFeatureString
{
    NSMutableString *featureString = [NSMutableString stringWithFormat:@"http://mobilis.inf.tu-dresden.de"];
    [featureString appendString:@"/service#servicenamespace=http://mobilis.inf.tu-dresden.de#services/ACDSenseService"];
    [featureString appendString:@",version=1,mode=single,rt=testserviceacds@localhost"];
    return featureString;
}

- (NSString *)buildServiceInstanceFeatureString
{
    NSMutableString *featureString = [NSMutableString stringWithFormat:@"http://mobilis.inf.tu-dresden.de"];
    [featureString appendString:@"/instance#servicenamespace=http://mobilis.inf.tu-dresden.de#services/ACDSenseService"];
    [featureString appendString:@",version=1,name=ACDSenseService,rt=testserviceacds@localhost"];
    return featureString;
}

#pragma mark - MXiMultiUserChatDelegate

- (void)connectionToRoomEstablished:(NSString *)roomJID
{
    NSLog(@"Connection to roomJID %@ successfully established.", roomJID);
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

@end