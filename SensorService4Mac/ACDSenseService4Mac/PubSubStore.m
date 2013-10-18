//
// Created by Martin Weißbach on 10/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import "PubSubStore.h"
#import "XMPPJID.h"

@interface PubSubStore ()

@property (strong, readwrite) NSArray *receivers;
@property (strong, readwrite) NSArray *publishers;

- (BOOL)validJID:(XMPPJID *)xmppjid andStore:(NSArray *)store;

@end

@implementation PubSubStore

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static PubSubStore *shared;
    dispatch_once(&once, ^ {
        shared = [[self alloc] initUniqueInstance];
    });
    return shared;
}

- (id)initUniqueInstance
{
    self.publishers = [NSArray array];
    self.receivers = [NSArray array];
    
    return [super init];
}

- (void)addReceiver:(XMPPJID *)receiver
{
    if (![self validJID:receiver andStore:self.receivers])
        return;

    NSMutableArray *tempStore = [NSMutableArray arrayWithArray:self.receivers];
    [tempStore addObject:receiver];
    self.receivers = [NSArray arrayWithArray:tempStore];
}

- (void)removeReceiver:(XMPPJID *)receiver
{
    if (![self.receivers containsObject:receiver])
        return;

    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.receivers];
    [tempArray removeObject:receiver];
    self.receivers = [NSArray arrayWithArray:tempArray];
}

- (void)addPublisher:(XMPPJID *)publisher
{
    if (![self validJID:publisher andStore:self.publishers])
        return;

    NSMutableArray *tempStore = [NSMutableArray arrayWithArray:self.publishers];
    [tempStore addObject:publisher];
    self.publishers = [NSArray arrayWithArray:tempStore];
}

- (void)removePublisher:(XMPPJID *)publisher
{
    if (![self.publishers containsObject:publisher])
        return;

    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.publishers];
    [tempArray removeObject:publisher];
    self.publishers = [NSArray arrayWithArray:tempArray];
}

#pragma mark - Helper Methods

- (BOOL)validJID:(XMPPJID *)xmppjid andStore:(NSArray *)store
{
    return !(!xmppjid || !store) && ![store containsObject:xmppjid];

}

@end