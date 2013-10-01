//
//  MainWindowController.h
//  DataGenerator
//
//  Created by Martin Weißbach on 9/25/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MXiConnection;

@interface MainWindowController : NSWindowController

@property (weak) MXiConnection *connection;

- (void)incomingWithIdentifier:(NSUInteger)identifier andDate:(NSDate *)date;

@end
