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
#import "DelegateDictionary.h"
#import "IncomingBeanDetection.h"

#import "DelegateSensorValues.h"

@interface ConnectionHandler ()

@property (strong, nonatomic) MXiConnection *connection;
@property (strong, nonatomic) NSArray *incomingBeans;

@property (weak) AuthenticationBlock authenticationBlock;

- (NSArray *)allIncomingBeans;

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

- (void)launchConnectionWithBlock:(AuthenticationBlock)authentication
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
                                  listeningForIncomingBeans:[self allIncomingBeans]];
    
    self.authenticationBlock = authentication;
}

- (void)launchConnectionWithJID:(NSString *)jabberID
                       password:(NSString *)password
                       hostName:(NSString *)hostName
                     serviceJID:(NSString *)serviceJabberID
            authenticationBlock:(AuthenticationBlock)authentication
{
    Account *account = [[Account alloc] initWithJID:jabberID
                                           password:password
                                           hostName:hostName
                                         serviceJID:serviceJabberID];
    [AccountManager storeAccount:account];
    [self launchConnectionWithBlock:authentication];
}

- (void)sendBean:(MXiBean<MXiOutgoingBean> *)outgoingBean
{
    if (self.connection && outgoingBean) {
        [self.connection sendBean:outgoingBean];
    }
}

#pragma mark ConnectionHandler Delgation Methods

- (void)addDelegate:(id<ConnectionHandlerDelegate>)delegate forBeanClass:(Class)beanClass
{
    [[DelegateDictionary sharedInstance] addDelegate:delegate forBeanClass:beanClass];
}

#pragma mark - MXiBeanDelegate

- (void)didReceiveBean:(MXiBean<MXiIncomingBean> *)theBean
{
    NSArray *delegates = [[DelegateDictionary sharedInstance] delegatesForBeanClass:[theBean class]];
    if (delegates) {
        for (id<ConnectionHandlerDelegate> delegate in delegates) {
            [delegate didReceiveBean:theBean];
        }
    }
}

#pragma mark - MXiPresenceDelegate

- (void)didAuthenticate
{
    self.authenticationBlock(YES);
}

- (void)didDisconnectWithError:(NSError *)error
{
#warning didDisconnectWithError: not implemented
    // TODO: figure out how this could best be handled
    // View that has initialized the connection might not be visible or allocated anymore
    self.connection = nil;
}

- (void)didFailToAuthenticate:(DDXMLElement *)error
{
    self.authenticationBlock(NO);
}

#pragma mark - Private Helper

- (NSArray *)allIncomingBeans
{
    if (self.incomingBeans) {
        return self.incomingBeans;
    }
    IncomingBeanDetection *incomingBeans = [IncomingBeanDetection new];
    self.incomingBeans = [incomingBeans detectBeans];
}

@end
