//
//  Timestamp+Description.m
//  ACDSense
//
//  Created by Martin Weißbach on 9/3/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "Timestamp+Description.h"

@implementation Timestamp (Description)

- (NSString *)timestampAsString
{
    NSMutableString *timestampString = [[NSMutableString alloc] init];
    [timestampString appendFormat:@"%02d/", self.month];
    [timestampString appendFormat:@"%02d/", self.day];
    [timestampString appendFormat:@"%d ", self.year];
    [timestampString appendFormat:@"%02d:", self.hour];
    [timestampString appendFormat:@"%02d:", self.minute];
    [timestampString appendFormat:@"%02d", self.second];
    
    return timestampString;
}

@end
