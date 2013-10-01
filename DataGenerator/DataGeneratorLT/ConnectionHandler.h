//
//  ConnectionHandler.h
//  ACDSenseWorkspace
//
//  Created by Martin Weißbach on 9/25/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

@class MXiConnection;
@class RoundtripInfo;

@protocol ConnectionhandlerDelegate

- (void)sendRoundtripItem:(RoundtripInfo *)roundtripInfo;

@end

@interface ConnectionHandler : NSObject

@property (nonatomic, weak) id<ConnectionhandlerDelegate> delegate;

@property (nonatomic, weak) MXiConnection *connection;
@property (nonatomic, strong) NSArray *roomJIDs;

- (id)initWithDelegate:(id<ConnectionhandlerDelegate>)delegate;
- (id)initWithDelegate:(id<ConnectionhandlerDelegate>)delegate andConnection:(MXiConnection *)connection;
- (id)initWithDelegate:(id<ConnectionhandlerDelegate>)delegate andConnection:(MXiConnection *)connection andRoomJIDs:(NSArray *)roomJIDs;

- (void)commenceTest;
- (void)finishTest;

@end
