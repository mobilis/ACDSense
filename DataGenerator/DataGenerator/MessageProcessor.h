//
//  MessageProcessor.h
//  ACDSenseWorkspace
//
//  Created by Martin Weißbach on 9/19/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//



@class SensorValue;

@interface MessageProcessor : NSObject

/**
*   Creates a string out of a sensorValue that has the following format:
*   {"sensorevent":{"type":"AMBIENT_TEMPERATURE","value":[20.34432],"timestamp":"2013-09-18T18:31:38+1:00"}}
*
*   @param sensorValue SensorValue to encode as multi-user-chat-message.
*   @param timestampAsString Timestamp in a string representation to use in the message.
*
*   @return A json-String that conforms to the example above.
*/
+ (NSString *)messageWithSensorValue:(SensorValue *)sensorValue;
+ (NSString *)messageWithSEnsorValue:(SensorValue *)sensorValue andTimestamp:(NSString *)timestampAsString;

/**
 *  Creates a string representation of a sensor value with the given test value as sensed value.
 *  {"sensorevent":{"type":"AMBIENT_TEMPERATURE","value":[20.34432],"timestamp":"2013-09-18T18:31:38+1:00"}}
 *
 *  @param testValue The testValue to encode in the json string.
 *
 *  @return A json-String that conforms to the example above.
 */
+ (NSString *)messageWithTestValue:(NSUInteger)testValue;

@end
