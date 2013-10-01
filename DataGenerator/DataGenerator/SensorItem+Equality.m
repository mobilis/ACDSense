//
//  SensorItem+Equality.m
//  ACDSenseWorkspace
//
//  Created by Martin Weißbach on 9/22/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SensorItem+Equality.h"

@implementation SensorItem (Equality)

- (BOOL)isSameSensor:(SensorItem *)otherSensorItem
{
    if (!otherSensorItem)
        return NO;

    return [self.sensorId isEqualToString:otherSensorItem.sensorId];
}

- (BOOL)isSameSensorID:(NSString *)otherSensorID
{
    if (!otherSensorID || otherSensorID.length == 0)
        return NO;

    return [self.sensorId isEqualToString:otherSensorID];
}


@end
