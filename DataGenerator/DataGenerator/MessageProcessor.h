//
//  MessageProcessor.h
//  ACDSenseWorkspace
//
//  Created by Martin Weißbach on 9/19/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//



@interface MessageProcessor : NSObject

+ (NSString *)messageWithSensorValue:(SensorValue *)sensorValue;
@end
