//
//  MUCInfoParser.m
//  DataGenerator
//
//  Created by Martin Weißbach on 9/3/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "MUCInfoParser.h"

#define UPPER_LIMIT 40.0
#define LOWER_LIMIT -20.0
#define STEPS 20

@interface MUCInfoParser ()

+ (NSArray *)splitLineIntoComponents:(NSString *)line;

@end

@implementation MUCInfoParser

+ (NSString *)parseMUCAddressFromString:(NSString *)string
{
    return [self splitLineIntoComponents:string][0];
}

+ (NSString *)parseSensorIDFromString:(NSString *)string
{
    return [self splitLineIntoComponents:string][1];
}

+ (NSArray *)splitLineIntoComponents:(NSString *)line
{
    return [line componentsSeparatedByString:@";"];
}

@end
