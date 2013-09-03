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

+ (NSString *)parseMUCTypeFromString:(NSString *)string
{
    return [self splitLineIntoComponents:string][1];
}

+ (float)parseLowerLimitFromString:(NSString *)string
{
    NSArray *components = [self splitLineIntoComponents:string];
    if (components.count < 3) {
        return LOWER_LIMIT;
    } else return components[2];
}

+ (float)parseUpperLimitFromString:(NSString *)string
{
    NSArray *components = [self splitLineIntoComponents:string];
    if (components.count < 4) {
        return UPPER_LIMIT;
    } else return components[3];
}

+ (NSInteger)parseIntermediaryStepsFromString:(NSString *)string
{
    NSArray *components = [self splitLineIntoComponents:string];
    if (components.count < 5) {
        return STEPS;
    } else return components[4];
}

+ (NSArray *)splitLineIntoComponents:(NSString *)line
{
    return [line componentsSeparatedByString:@";"];
}

@end
