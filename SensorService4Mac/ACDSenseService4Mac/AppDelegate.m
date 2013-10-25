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

static void *KVOContext = &KVOContext;

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
                                                       //   Callback not reached because no services will be discovered usually
                                                       //   when you test against a Mobilis not running any single services.
                                                       //   Therefor the KVO workaround to determine nonetheless if and when
                                                       //   the authentication finished successfully.
//                                                       self.server = [ServerComponent sharedInstance];
//                                                       [self.server synchronizeRuntimes];
                                                   }
                                               }];

    [[MXiConnectionHandler sharedInstance] addObserver:self
                                            forKeyPath:@"authenticated"
                                               options:NSKeyValueObservingOptionNew
                                               context:KVOContext];
}
- (Account *)defaultAccountInformation
{
    DefaultSettings *settings = [DefaultSettings defaultSettings];

    return [[Account alloc] initWithJID:[settings valueForKey:SERVICE_JID]
                               password:[settings valueForKey:SERVICE_PASSWORD]
                               hostName:[settings valueForKey:SERVER_HOSTNAME]
                                   port:[NSNumber numberWithInteger:[[settings valueForKey:SERVER_PORT] integerValue]]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"authenticated"] && context == KVOContext) {
        NSLog(@"The user got authenticated without disco completing.");

        self.server = [ServerComponent sharedInstance];
        [[MXiConnectionHandler sharedInstance] performSelector:@selector(setConnected:) withObject:[NSNumber numberWithBool:YES ]];
        [self.server synchronizeRuntimes];
    }
}

@end
