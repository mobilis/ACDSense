#import "PublishSensorValues.h"

@implementation PublishSensorValues

@synthesize sensorValues;

- (id)init {
	self = [super initWithBeanType:SET];
    if (self) {
        self.sensorValues = [NSMutableArray arrayWithCapacity:2];
    }
	
	return self;
}

- (NSXMLElement* )toXML {
	NSXMLElement* beanElement = [NSXMLElement elementWithName:[[self class] elementName]
														xmlns:[[self class] iqNamespace]];
    
	for (SensorValue* sensorValuesPart in sensorValues) {
		NSXMLElement* sensorValueElement = [NSXMLElement elementWithName:@"SensorValue"];
        
        NSXMLElement *value = [NSXMLElement elementWithName:@"value" stringValue:sensorValuesPart.value];
        NSXMLElement *unit = [NSXMLElement elementWithName:@"unit" stringValue:sensorValuesPart.unit];
        NSXMLElement *type = [NSXMLElement elementWithName:@"type" stringValue:sensorValuesPart.type];
        [sensorValueElement addChild:value];
        [sensorValueElement addChild:unit];
        [sensorValueElement addChild:type];
        if (sensorValuesPart.location) {
            NSXMLElement *location = [NSXMLElement elementWithName:@"location" stringValue:sensorValuesPart.location];
            [sensorValueElement addChild:location];
        }

		[beanElement addChild:sensorValueElement];
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