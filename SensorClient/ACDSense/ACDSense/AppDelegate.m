//
//  AppDelegate.m
//  ACDSense
//
//  Created by Martin Weißbach on 8/19/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "AppDelegate.h"
#import "AccountManager.h"

#import "RegisterReceiver.h"
#import "RemoveReceiver.h"

@interface AppDelegate ()
- (void) launchConnectionEstablishment;
@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self launchConnectionEstablishment];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[MXiConnectionHandler sharedInstance] sendBean:[RemoveReceiver new]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - MXi Communication

- (void)launchConnectionEstablishment
{
	Account *account = [AccountManager account];
	if (account && account.hostName && account.hostName.length > 0) {
        [[MXiConnectionHandler sharedInstance] launchConnectionWithJID:account.jid
                                                              password:account.password
                                                              hostName:account.hostName
                                                           serviceType:SINGLE
                                                                  port:account.port
                                                   authenticationBlock:^(BOOL success) {
                                                       if (success) {
                                                           [[MXiConnectionHandler sharedInstance] sendBean:[RegisterReceiver new]];
                                                       }
                                                   }];
	} else {
		NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
		NSDictionary *jabberSettings = [[NSDictionary dictionaryWithContentsOfFile:settingsPath] objectForKey:@"jabberInformation"];
		
		NSString *jid = [jabberSettings valueForKey:@"jid"];
		NSString *password = [jabberSettings valueForKey:@"password"];
		NSString *hostName = [jabberSettings valueForKey:@"hostName"];
        NSNumber *port = [jabberSettings valueForKey:@"port"];
		
        [[MXiConnectionHandler sharedInstance] launchConnectionWithJID:jid
                                                              password:password
                                                              hostName:hostName
                                                           serviceType:SINGLE
                                                                  port:port
                                                   authenticationBlock:^(BOOL success) {
                                                       if (success) {
                                                           [[MXiConnectionHandler sharedInstance] sendBean:[RegisterReceiver new]];
                                                       }
                                                   }];
	}
}

@end
