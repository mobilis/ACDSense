//
// Created by Martin Weißbach on 10/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import <Foundation/Foundation.h>

@class XMPPJID;


@interface PubSubStore : NSObject

@property (strong, readonly) NSArray *receivers;
@property (strong, readonly) NSArray *publishers;

+ (instancetype)sharedInstance;

- (void)addReceiver:(XMPPJID *)receiver;
- (void)removeReceiver:(XMPPJID *)receiver;

- (void)addPublisher:(XMPPJID *)publisher;
- (void)removePublisher:(XMPPJID *)publisher;

@end