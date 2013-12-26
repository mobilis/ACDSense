//
//  AppDelegate.m
//  ACDSenseService4Mac
//
//  Created by Martin Weißbach on 10/16/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <MXiConnection.h>
#import "AppDelegate.h"
#import "Account.h"
#import "DefaultSettings.h"
#import "ServerComponent.h"

@interface AppDelegate () <MXiConnectionHandlerDelegate>

@property (strong) ServerComponent *server;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self launchService];
}
- (void)launchService
{
    Account *account = [self defaultAccountInformation];
    [MXiConnectionHandler sharedInstance].delegate = self;
    [[MXiConnectionHandler sharedInstance] launchConnectionWithJID:account.jid
                                                          password:account.password
                                                          hostName:account.hostName
                                                       serviceType:SINGLE
                                                              port:account.port];
}

- (Account *)defaultAccountInformation
{
    DefaultSettings *settings = [DefaultSettings defaultSettings];

    return [[Account alloc] initWithJID:[settings valueForKey:SERVICE_JID]
                               password:[settings valueForKey:SERVICE_PASSWORD]
                               hostName:[settings valueForKey:SERVER_HOSTNAME]
                                   port:[NSNumber numberWithInteger:[[settings valueForKey:SERVER_PORT] integerValue]]];
}

#pragma mark - MXiConnectionHandlerDelegate

- (void)authenticationFinishedSuccessfully:(BOOL)authenticationState
{
    self.server = [ServerComponent sharedInstance];
    [self.server synchronizeRuntimes];
}

- (void)connectionDidDisconnect:(NSError *)error
{
    NSLog(@"connectionDidDisconnect: %@", error);
}

- (void)serviceDiscoveryError:(NSError *)error
{
    NSLog(@"serviceDiscoveryError: %@", error);
}

@end
