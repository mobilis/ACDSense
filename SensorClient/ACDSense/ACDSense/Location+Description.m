//
//  Location+Description.m
//  ACDSense
//
//  Created by Martin Weißbach on 9/2/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "Location+Description.h"

@implementation Location (Description)

- (NSString *)locationAsString
{
    NSString *string = [NSString stringWithFormat:@"Longitude: %d, Latitude: %d", self.longitude, self.latitude];
    return string;
}

@end
