//
//  RefreshTimer.m
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "RefreshTimer.h"

@interface RefreshTimer ()

@property (strong, nonatomic) NSTimer *timer;

- (void)initTimer;

@end

@implementation RefreshTimer

- (id)init
{
    self = [super init];
    if (self) {
        self.target = nil;
        self.selector = nil;
        self.timer = nil;
    }
    return self;
}

- (id)initWithTarget:(id)target invokeMethod:(SEL)method
{
    self = [super init];
    if (self) {
        self.target = target;
        self.selector = method;
        [self initTimer];
    }
    return self;
}

- (void)initTimer
{
    NSString *settingsFilePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:settingsFilePath];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[[settings valueForKey:@"valueCreationInterval"] doubleValue]
                                                  target:self.target
                                                selector:self.selector
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stop
{
    [self.timer invalidate];
}

- (void)restart
{
    if (![self.timer isValid]) {
        [self initTimer];
    }
}

@end
