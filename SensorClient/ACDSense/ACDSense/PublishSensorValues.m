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