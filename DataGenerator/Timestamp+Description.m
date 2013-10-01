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
    // 2013-09-18T18:31:38+1:00
    NSMutableString *timestampString = [[NSMutableString alloc] init];
    [timestampString appendFormat:@"%li-", self.year];
    [timestampString appendFormat:@"%02li-", self.month];
    [timestampString appendFormat:@"%02liT", self.day];
    [timestampString appendFormat:@"%02li:", self.hour];
    [timestampString appendFormat:@"%02li:", self.minute];
    [timestampString appendFormat:@"%02li+01:00", self.second];
    
    return timestampString;
}

@end
