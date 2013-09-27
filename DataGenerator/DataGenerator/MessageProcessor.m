//
//  MessageProcessor.m
//  ACDSenseWorkspace
//
//  Created by Martin Weißbach on 9/19/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "MessageProcessor.h"
#import "SensorValue.h"
#import "Timestamp+Description.h"

@implementation MessageProcessor

+ (NSString *)messageWithSensorValue:(SensorValue *)sensorValue
{
    return [self messageWithSEnsorValue:sensorValue andTimestamp:nil];
}

+ (NSString *)messageWithSEnsorValue:(SensorValue *)sensorValue andTimestamp:(NSString *)timestampAsString
{
    NSString *timestamp = nil;
    if (timestampAsString)
        timestamp = timestampAsString;
    else {
        NSDate *date = [NSDate date];
        unsigned long components = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [currentCalendar components:components fromDate:date];
        
        NSMutableString *timestampBuilder = [NSMutableString new];
        [timestampBuilder appendFormat:@"%ld-", (long)dateComponents.year];
        [timestampBuilder appendFormat:@"%02ld-", (long)dateComponents.month];
        [timestampBuilder appendFormat:@"%02ldT", (long)dateComponents.day];
        [timestampBuilder appendFormat:@"%02ld:", (long)dateComponents.hour];
        [timestampBuilder appendFormat:@"%02ld:", (long)dateComponents.minute];
        [timestampBuilder appendFormat:@"%02ld+01:00", (long)dateComponents.second];
        
        timestamp = [NSString stringWithString:timestampBuilder];
    }
    
    // {"sensorevent":{"type":"AMBIENT_TEMPERATURE","value":[20.34432],"timestamp":"2013-09-18T18:31:38+1:00"}}
    NSMutableString *jsonString = [NSMutableString stringWithCapacity:100];
    [jsonString appendString:@"{\"sensorevent\":{\"type\":\""];
    [jsonString appendFormat:@"%@",sensorValue.subType];
    [jsonString appendString:@"\",\"values\":["];
    [jsonString appendString:sensorValue.value];
    [jsonString appendString:@"],\"timestamp\":\""];
    [jsonString appendString:timestamp];
    [jsonString appendString:@"\"}}"];
    
    return jsonString;
}

+ (NSString *)messageWithTestValue:(NSUInteger)testValue
{
    // {"sensorevent":{"type":"AMBIENT_TEMPERATURE","values":[20.34432],"timestamp":"2013-09-18T18:31:38+1:00"}}
    // The value in the Array is the packet identifier.
    return [NSString stringWithFormat:@"{\"sensorevent\":{\"type\":\"AMBIENT_TEMPERATURE\",\"values\":[%i],\"timestamp\":\"2013-09-18T18:31:38+1:00\"}}",testValue];
}


@end
