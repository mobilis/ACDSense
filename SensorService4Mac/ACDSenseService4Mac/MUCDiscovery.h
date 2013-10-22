//
// Created by Martin Weißbach on 10/21/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import <Foundation/Foundation.h>

@class ACDSMultiUserChatRoom;
@class MXiMultiUserChatRoom;
@class XMPPIQ;


@interface MUCDiscovery : NSObject

+ (id)discoverWithRoom:(MXiMultiUserChatRoom *)room completionBlock:(void (^)(BOOL isSensorMUC, ACDSMultiUserChatRoom *acdsroom))completionBlock;

- (id)initWithRoom:(MXiMultiUserChatRoom *)room completionBlock:(void (^)(BOOL, ACDSMultiUserChatRoom *))block;

- (void)iqStanzaReceived:(XMPPIQ *)iq;

@end