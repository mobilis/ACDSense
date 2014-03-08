//
// Created by Martin Weissbach on 3/1/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import "MUCMessageProcessor.h"
#import "SBJson4Parser.h"
#import "SensorItem.h"


@implementation MUCMessageProcessor
{
    __strong SensorItem *_sensorItem;
}

+ (instancetype)processJSONString:(NSString *)jsonString andSensorID:(NSString *)sensorID
{
    return [[self alloc] initWithJSONString:jsonString andSensorID:sensorID];
}

- (id)initWithJSONString:(NSString *)jsonString andSensorID:(NSString *)sensorID
{
    if (self = [super init])
    {
        _sensorItem = [SensorItem new];
        _sensorItem.sensorId = sensorID;
        _sensorItem.sensorDescription = sensorID;
        _sensorItem.values = [NSMutableArray arrayWithCapacity:5];

        SBJson4Parser *json4Parser = [SBJson4Parser parserWithBlock:^(id element, BOOL *stop)
        {
            [self parseElement:element];
        }
                                                     allowMultiRoot:NO
                                                    unwrapRootArray:NO
                                                       errorHandler:^(NSError *error)
                                                       {
                                                           @throw [NSException exceptionWithName:@"JSON Parser error" reason:[NSString stringWithFormat:@"%i", error.code] userInfo:error.userInfo];
                                                       }];

        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (!jsonData) @throw [NSException exceptionWithName:@"JSON to Data error" reason:@"Json could not be converted to NSData" userInfo:nil];

        if (SBJson4ParserComplete == [json4Parser parse:jsonData]) return self;

    }
    return self;
}

#pragma mark - Public Interface

- (SensorItem *)processedJSON
{
    return _sensorItem;
}

#pragma mark - JSON Processor Methods

- (void)parseElement:(id)element
{
    if ([element isKindOfClass:[NSMutableDictionary class]])
        [self parseObjectElement:(NSMutableDictionary *)element];
}

- (void)parseObjectElement:(NSMutableDictionary *)dictionary
{
    NSMutableDictionary *eventDictionary = [dictionary valueForKey:@"sensorevent"];
    if (eventDictionary)
    {
        _sensorItem.type = [eventDictionary valueForKey:@"type"];
        [self parseArrayElement:(NSMutableArray *)[eventDictionary valueForKey:@"values"]];
        for (SensorValue *value in _sensorItem.values)
        {
            value.timestamp = [self parseTimestamp:(NSString *)[eventDictionary valueForKey:@"timestamp"]];
            value.subType = _sensorItem.type;
        }
    }
}

- (Timestamp *)parseTimestamp:(NSString *)string
{
    NSArray *tSep = [string componentsSeparatedByString:@"T"];
    if (tSep.count != 2) return nil;

    NSArray *ymdComp = [((NSString *) tSep[0]) componentsSeparatedByString:@"-"];
    if (ymdComp.count != 3) return nil;

    Timestamp *timestamp = [Timestamp new];
    timestamp.year = [ymdComp[0] integerValue];
    timestamp.month = [ymdComp[1] integerValue];
    timestamp.day = [ymdComp[2] integerValue];

    NSArray *dateZone = [((NSString *) tSep[1]) componentsSeparatedByString:@"+"];
    if (dateZone.count != 2) return nil;
    NSArray *hmsComp = [((NSString *) dateZone[0]) componentsSeparatedByString:@":"];
    if (hmsComp.count != 3) return nil;

    timestamp.hour = [hmsComp[0] integerValue];
    timestamp.minute = [hmsComp[1] integerValue];
    timestamp.second = [hmsComp[2] integerValue];

    return timestamp;
}

- (void)parseArrayElement:(NSMutableArray *)array
{
    for (id value in array)
    {
        SensorValue *sensorValue = [SensorValue new];
        sensorValue.value = [NSString stringWithFormat:@"%@", value];

        [_sensorItem.values addObject:sensorValue];
    }
}

@end