//
//  AppDelegate.m
//  DataGeneratorLT
//
//  Created by Martin Weißbach on 9/25/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <MXi/MXi.h>
#import "AppDelegate.h"
#import "MainWindowController.h"
#import "DelegateSensorItems.h"
#import "RegisterReceiver.h"
#import "CreateSensorMUCDomain.h"

@interface AppDelegate () <MXiBeanDelegate, MXiPresenceDelegate, MXiStanzaDelegate>

@property (strong) MainWindowController *mainWindowController;

@property (strong) MXiConnection *connection;

- (void)launchConnectionEstablishment;
- (NSArray *)incomingBeans;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self launchConnectionEstablishment];
}

#pragma mark - Connection Wrapping

- (void)launchConnectionEstablishment
{
    @autoreleasepool {
        NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:settingsPath];

        self.connection = [MXiConnection connectionWithJabberID:[settingsDictionary objectForKey:@"jid"]
                                                       password:[settingsDictionary objectForKey:@"password"]
                                                       hostName:[settingsDictionary objectForKey:@"hostName"]
                                                           port:[[settingsDictionary objectForKey:@"port"] integerValue]
                                                 coordinatorJID:[NSString stringWithFormat:@"mobilis@%@/Coordinator", [settingsDictionary objectForKey:@"hostName"]]
                                               serviceNamespace:[settingsDictionary objectForKey:@"serviceNamespace"]
                                               presenceDelegate:self
                                                 stanzaDelegate:self
                                                   beanDelegate:self
                                      listeningForIncomingBeans:[self incomingBeans]];
    }
}

- (NSArray *)incomingBeans
{
    return @[[[DelegateSensorItems alloc] init]];
}

#pragma mark - MXiStanzaDelegate

- (BOOL)didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"Did receive IQ: %@", iq);
    return YES;
}

- (void)didReceivePresence:(XMPPPresence *)presence
{
    NSLog(@"Did receive presence: %@", presence);
}

- (void)didReceiveError:(NSXMLElement *)error
{
    NSLog(@"Did receive error: %@", error);
}

- (void)didReceiveMessage:(XMPPMessage *)message
{
    #warning Not implemented method.
}

#pragma mark - MXiPresenceDelegate

- (void)didAuthenticate
{
    NSLog(@"Successfully authenticated.");
}

- (void)didDiscoverServiceWithNamespace:(NSString *)serviceNamespace
                                   name:(NSString *)serviceName
                                version:(NSInteger)version
                             atJabberID:(NSString *)serviceJID
{
    self.mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    self.mainWindowController.connection = self.connection;

    [self.mainWindowController.window makeKeyAndOrderFront:self];
    [self.mainWindowController showWindow:self];

    CreateSensorMUCDomain *domain = [[CreateSensorMUCDomain alloc] init];
    domain.sensorDomain = [[SensorMUCDomain alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:filePath];
    domain.sensorDomain.domainURL = [settings valueForKey:@"hostName"];

    [self.connection sendBean:[[RegisterReceiver alloc] init]];
    [self.connection sendBean:domain];
}

#pragma mark - MXiBeanDelegate

- (void)didReceiveBean:(MXiBean <MXiIncomingBean> *)theBean
{
    if ([theBean isKindOfClass:[DelegateSensorItems class]]) {
        DelegateSensorItems *delegateSensorItems = (DelegateSensorItems *)theBean;
        NSArray *sensorItems = delegateSensorItems.sensorItems;
        for (SensorItem *item in sensorItems)
            for (SensorValue *value in item.values)
                [self.mainWindowController incomingWithIdentifier:(NSUInteger) [value.value integerValue]
                                                          andDate:[NSDate date]];
    }
}

@end
