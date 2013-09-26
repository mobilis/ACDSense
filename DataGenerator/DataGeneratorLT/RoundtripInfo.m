//
//  RoundtripInfo.m
//  ACDSenseWorkspace
//
//  Created by Martin Weißbach on 9/25/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "RoundtripInfo.h"

@interface RoundtripInfo () {
    __strong NSString *_received;
}

@property (strong) NSString *roundtrip;

@end

@implementation RoundtripInfo

- (id)initWithStartDate:(NSDate *)startDate andIdentifier:(NSUInteger)roundtripIdentifier
{
    self = [super init];
    if (self) {
        self.sent = [startDate descriptionWithLocale:nil];
        self.received = nil;
        self.roundtrip = nil;
        self.roundtripIdentifier = roundtripIdentifier;
    }

    return self;
}

- (BOOL)isSameIdentifier:(NSUInteger)otherIdentifier
{
    return (self.roundtripIdentifier == otherIdentifier) ? YES : NO;
}


#pragma mark - Custom Getter & Setter

- (void)setReceived:(NSString *)received
{
    @synchronized (_received) {
        _received = received;

        NSDate *receivedDate = [NSDate dateWithString:received];
        self.roundtrip = [NSString stringWithFormat:@"%f", [receivedDate timeIntervalSinceDate:[NSDate dateWithString:self.sent]]];
    }
}

- (NSString *)received
{
    @synchronized (_received) {
        return [_received copy];
    }
}

@end
