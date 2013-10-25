//
// Created by Martin Weißbach on 10/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import "ServerComponent.h"
#import "MXiConnectionHandler.h"
#import "RegisterPublisher.h"
#import "RegisterReceiver.h"
#import "CreateSensorMUCDomain.h"
#import "RemovePublisher.h"
#import "RemoveReceiver.h"
#import "PubSubStore.h"
#import "SynchronizeRuntimeBean.h"


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
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(registerPublisher:) forBeanClass:[RegisterPublisher class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(registerReceiver:) forBeanClass:[RegisterReceiver class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(removePublisher:) forBeanClass:[RemovePublisher class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(removeReceiver:) forBeanClass:[RemoveReceiver class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(createMUCDomain:) forBeanClass:[CreateSensorMUCDomain class]];

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
                                                                  // TODO: add rooms to list for service – discover SensorMUCs
                                                              }
                                                          }];
    // TODO: connect to Multi-User-Chat-Rooms
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

@end