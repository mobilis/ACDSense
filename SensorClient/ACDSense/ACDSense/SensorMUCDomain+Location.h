//
// Created by Martin Weissbach on 3/10/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorMUCDomain.h"

@class Location;

@interface SensorMUCDomain (Location)

@property (nonatomic) Location *location;

@end