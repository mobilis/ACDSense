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
    [timestampString appendFormat:@"%02li/", self.month];
    [timestampString appendFormat:@"%02li/", self.day];
    [timestampString appendFormat:@"%li ", self.year];
    [timestampString appendFormat:@"%02li:", self.hour];
    [timestampString appendFormat:@"%02li:", self.minute];
    [timestampString appendFormat:@"%02li", self.second];
    
    return timestampString;
}

@end
