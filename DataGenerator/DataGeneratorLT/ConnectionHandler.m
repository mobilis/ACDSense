//
//  ConnectionHandler.m
//  ACDSenseWorkspace
//
//  Created by Martin Weißbach on 9/25/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <MXi/MXi.h>
#import "ConnectionHandler.h"
#import "MessageProcessor.h"
#import "RoundtripInfo.h"

#define REPETITIONS 10

@interface ConnectionHandler ()

@property (strong) NSTimer *senderTimer;
@property (strong) NSOperationQueue *backgroundQueue;
@property NSUInteger repetitionCounter;
@property NSUInteger packetIdentifier;

@end

@implementation ConnectionHandler

- (id)initWithDelegate:(id<ConnectionhandlerDelegate>)delegate
{
    return [self initWithDelegate:delegate andConnection:nil];
}

- (id)initWithDelegate:(id <ConnectionhandlerDelegate>)delegate andConnection:(MXiConnection *)connection
{
    return [self initWithDelegate:delegate andConnection:connection andRoomJIDs:nil];
}

- (id)initWithDelegate:(id <ConnectionhandlerDelegate>)delegate andConnection:(MXiConnection *)connection andRoomJIDs:(NSArray *)roomJIDs
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.connection = connection;
        self.roomJIDs = roomJIDs;

        self.senderTimer = nil;
        self.repetitionCounter = 0;
        self.backgroundQueue = [NSOperationQueue new];
    }

    return self;
}

#pragma mark - Start / Stop Test

- (void)commenceTest
{
    [self updateTimerWithInterval:5.0];
}

- (void)finishTest
{
    [self.senderTimer invalidate];
    self.senderTimer = nil;
}

#pragma mark - (Re-)Schedule Timer & Fire

- (void)updateTimerWithInterval:(double)interval
{
    self.repetitionCounter = 0;
    [self.senderTimer invalidate];
    self.senderTimer = [NSTimer timerWithTimeInterval:interval
                                               target:self
                                             selector:@selector(fireMessage)
                                             userInfo:nil
                                              repeats:REPETITIONS];
    [[NSRunLoop mainRunLoop] addTimer:self.senderTimer forMode:NSDefaultRunLoopMode];
}
- (void)fireMessage
{
    if (self.repetitionCounter == (NSUInteger) REPETITIONS)
        [self updateTimerWithInterval:[self.senderTimer timeInterval] / 2.0];
    else {
        [self.backgroundQueue addOperationWithBlock:^
        {
            for (NSString *roomJID in self.roomJIDs) {
                RoundtripInfo *roundtripInfo = [[RoundtripInfo alloc] initWithStartDate:[NSDate date]
                                                                          andIdentifier:self.packetIdentifier];
                [self.connection sendMessage:[MessageProcessor messageWithTestValue:roundtripInfo.roundtripIdentifier]
                                      toRoom:roomJID];
                self.packetIdentifier = self.packetIdentifier + 1;
                [self.delegate sendRoundtripItem:roundtripInfo];
            }
        }];
        self.repetitionCounter = self.repetitionCounter + 1;
    }
    
}

@end
