//
//  AppDelegate.m
//  ACDSenseService4Mac
//
//  Created by Martin Weißbach on 10/16/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <MobilisMXi/MXi/MXiConnectionHandler.h>
#import "AppDelegate.h"
#import "Account.h"
#import "DefaultSettings.h"
#import "ServerComponent.h"

@interface AppDelegate ()

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
    [[MXiConnectionHandler sharedInstance] launchConnectionWithJID:account.jid
                                                          password:account.password
                                                          hostName:account.hostName
                                                       serviceType:SINGLE
                                                              port:account.port
                                               authenticationBlock:^(BOOL authenticationSuccessful)
                                               {
                                                   NSLog(@"Service connection finished with status: %i", authenticationSuccessful);
                                                   if (authenticationSuccessful) {
                                                       self.server = [ServerComponent sharedInstance];
                                                   }
                                               }];
}
- (Account *)defaultAccountInformation
{
    DefaultSettings *settings = [DefaultSettings defaultSettings];

    return [[Account alloc] initWithJID:[settings valueForKey:SERVICE_JID]
                               password:[settings valueForKey:SERVICE_PASSWORD]
                               hostName:[settings valueForKey:SERVER_HOSTNAME]
                                   port:[NSNumber numberWithInteger:[[settings valueForKey:SERVER_PORT] integerValue]]];
}

@end
