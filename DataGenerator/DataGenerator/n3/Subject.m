//
//  Subject.m
//  DataGenerator
//
//  Created by Martin Weißbach on 9/14/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "Subject.h"

@interface Subject ()

- (void)retrieveLocationInformationFromString:(NSString *)string;
- (void)retrieveSensorInformation:(NSString *)string;

@end

@implementation Subject

+ (id)subjectWithComponents:(NSArray *)components
{
    return [[self alloc] initWithComponents:components];
}

- (id)initWithComponents:(NSArray *)components
{
    self = [super init];
    if (self) {
        NSRange range = NSMakeRange(0, 30);
        for (NSString *component in components) {
            if (![[component substringToIndex:1] compare:@"@" options:NSCaseInsensitiveSearch]) {
                if ([component rangeOfString:@"System" options:NSCaseInsensitiveSearch range:range].location != NSNotFound) {
                    [self retrieveSensorInformation:component];
                    continue;
                }
                if ([component rangeOfString:@"point" options:NSCaseInsensitiveSearch range:range].location != NSNotFound) {
                    [self retrieveLocationInformation:component];
                    continue;
                }
            }
        }
    }
    return self;
}

#pragma mark - Private Methods

- (void)retrieveLocationInformation:(NSString *)string
{
    NSString *latitude = nil;
    NSString *longitude = nil;
    NSString *elevation = nil;

    NSArray *subcomponents = [string componentsSeparatedByString:@";"];
    for (NSString *property in subcomponents) {
        NSUInteger lastQuotationMark = [property rangeOfString:@"^^"].location - 1;
        if ([property rangeOfString:@"alt"].location != NSNotFound) {
            elevation = [property substringWithRange:NSMakeRange([property rangeOfString:@"alt"].location + 5, lastQuotationMark)];
            continue;
        }
        if ([property rangeOfString:@"lat"].location != NSNotFound) {
            latitude = [property substringWithRange:NSMakeRange([property rangeOfString:@"lat"].location + 5, lastQuotationMark)];
            continue;
        }
        if ([property rangeOfString:@"long"].location != NSNotFound) {
            longitude = [property substringWithRange:NSMakeRange([property rangeOfString:@"long"].location + 6, lastQuotationMark)];
            continue;
        }
    }

    self.location = @{  @"latitude": latitude,
                        @"longitude": longitude,
                        @"elevation": elevation };
}

- (void)retrieveSensorInformation:(NSString *)string
{
#warning Unimplemented retrieveSensorInformation Method in Subject
    NSArray *subcomponents = [string componentsSeparatedByString:@";"];
    for (NSString *property in subcomponents) {
        if ([property rangeOfString:@"ID"].location != NSNotFound) {
            NSArray *keyValue = [property componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            self.identifier = [[((NSString *) keyValue[1]) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                    stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            continue;
        }
        if ([property rangeOfString:@"parameter"].location != NSNotFound) {
            NSRange range = NSMakeRange(0, [property rangeOfString:@"parameter"].length + 1);
            NSString *weatherInfo = [property stringByReplacingCharactersInRange:range withString:@""];
            NSArray *weatherKeys = [weatherInfo componentsSeparatedByString:@","];
            
            NSMutableArray *finalWeatherKeys = [NSMutableArray arrayWithCapacity:weatherKeys.count];
            for (NSString *weatherKey in weatherKeys) {
                NSString *finalKey = [weatherKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [finalWeatherKeys addObject:[finalKey stringByReplacingOccurrencesOfString:@"weather:" withString:@""]];
            }
            self.weatherKeys = [NSArray arrayWithArray:finalWeatherKeys];
        }
    }
}


@end
