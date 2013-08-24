//
//  ConnectionHandler.m
//  ACDSense
//
//  Created by Martin Weißbach on 8/24/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "ConnectionHandler.h"

#import "Account.h"
#import "AccountManager.h"

@interface ConnectionHandler ()

@property (strong, nonatomic) MXiConnection *connection;

@end

@implementation ConnectionHandler

#pragma mark - Singleton stack

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    __strong static ConnectionHandler *shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[super alloc] initUniqueInstance];
    });
    return shared;
}

- (instancetype)initUniqueInstance
{
    return [super init];
}

#pragma mark - Connection Handling

- (void)launchConnection
{
    if (self.connection) {
        [self.connection disconnect];
        self.connection = nil;
    }
    
    Account *account = [AccountManager account];
    self.connection = [MXiConnection connectionWithJabberID:account.jid
                                                   password:account.password
                                                   hostName:account.hostName
                                                 serviceJID:account.serviceJID
                                           presenceDelegate:self
                                             stanzaDelegate:self
                                               beanDelegate:self
                                  listeningForIncomingBeans:@[]]; // TODO: setup incoming bean delegates
}

- (void)launchConnectionWithJID:(NSString *)jabberID password:(NSString *)password hostName:(NSString *)hostName serviceJID:(NSString *)serviceJabberID
{
    Account *account = [[Account alloc] initWithJID:jabberID password:password hostName:hostName serviceJID:serviceJabberID];
    [AccountManager storeAccount:account];
    [self launchConnection];
}


@end
