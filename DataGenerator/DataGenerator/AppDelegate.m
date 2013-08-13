//
//  AppDelegate.m
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

- (void)scheduleNewValueCalculation;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.refreshTimer = [[RefreshTimer alloc] initWithTarget:self invokeMethod:@selector(scheduleNewValueCalculation)];
    self.tempValueCalculator = [[TempValueCalculator alloc] init];
}

- (void)scheduleNewValueCalculation
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        // TODO: Implement transmission of temp value to Mobilis service here.
        NSLog(@"%f", [[self.tempValueCalculator nextValue] floatValue]);
    });
}

@end
