#import "PublishSensorValues.h"

@implementation PublishSensorValues

@synthesize sensorValues;

- (id)init {
	self = [super initWithBeanType:SET];
	
	return self;
}

- (NSXMLElement* )toXML {
	NSXMLElement* beanElement = [NSXMLElement elementWithName:[[self class] elementName]
														xmlns:[[self class] iqNamespace]];

	for (SensorValue* sensorValuesPart in sensorValues) {
		NSXMLElement* sensorValuesElement = [NSXMLElement elementWithName:@"sensorValues"];
        
        NSXMLElement *value = [NSXMLElement elementWithName:@"value" stringValue:sensorValuesPart.value];
        NSXMLElement *unit = [NSXMLElement elementWithName:@"unit" stringValue:sensorValuesPart.unit];
        NSXMLElement *type = [NSXMLElement elementWithName:@"type" stringValue:sensorValuesPart.type];
        [sensorValuesElement addChild:value];
        [sensorValuesElement addChild:unit];
        [sensorValuesElement addChild:type];
        if (sensorValuesPart.location) {
            NSXMLElement *location = [NSXMLElement elementWithName:@"location" stringValue:sensorValuesPart.location];
            [sensorValuesElement addChild:location];
        }

		[beanElement addChild:sensorValuesElement];
	}

	return beanElement;
}

+ (NSString* )elementName {
	return @"PublishSensorValues";
}

+ (NSString* )iqNamespace {
	return @"acdsense:iq:publishsensorvalues";
}

@end