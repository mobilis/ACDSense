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
    // {"sensorevent":{"type":"AMBIENT_TEMPERATURE","value":[20.34432],"timestamp":"2013-09-18T18:31:38+1:00"}}
    NSMutableString *jsonString = [NSMutableString stringWithCapacity:100];
    [jsonString appendString:@"{\"sensorevent\":{\"type\":\""];
    [jsonString appendFormat:@"%@",sensorValue.subType];
    [jsonString appendString:@"\",\"value\":["];
    [jsonString appendString:sensorValue.value];
    [jsonString appendString:@"],\"timestamp\":\""];
    [jsonString appendString:[sensorValue.timestamp timestampAsString]];
    [jsonString appendString:@"\"}}"];

    return jsonString;
}

@end
