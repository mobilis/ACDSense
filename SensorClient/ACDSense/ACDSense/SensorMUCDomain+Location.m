//
// Created by Martin Weissbach on 3/10/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <objc/runtime.h>
#import "SensorMUCDomain+Location.h"
#import "Location.h"


#define kSMUCDLocationKey @"kSMUCDLocationKey"

@implementation SensorMUCDomain (Location)

- (void)setLocation:(Location *)location
{
    objc_setAssociatedObject(self, kSMUCDLocationKey, location, OBJC_ASSOCIATION_RETAIN);
}

- (Location *)location
{
    return objc_getAssociatedObject(self, kSMUCDLocationKey);
}

@end