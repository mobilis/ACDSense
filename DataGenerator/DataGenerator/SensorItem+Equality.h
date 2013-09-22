//
//  SensorItem+Equality.h
//  ACDSenseWorkspace
//
//  Created by Martin Weißbach on 9/22/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//



#import "SensorItem.h"

@interface SensorItem (Equality)

/**
*   Checks if the given sensor item represents the same physical sensor than the receiver.
*
*   @param otherSensorItem A sensor item to check for equality.
*
*   @return YES, if sensor id's of receiver and attribute are equal.
*/
- (BOOL)isSameSensor:(SensorItem *)otherSensorItem;

/**
*   Checks if the given sensor id represents the sensor item of the receiver.
*
*   @param otherSensorID A string representation of the sensor id to compare.
*
*   @return YES, if the sensor id of the receiver equals otherSensorID.
*/
- (BOOL)isSameSensorID:(NSString *)otherSensorID;
@end
