#import "DelegateSensorValues.h"

@implementation DelegateSensorValues

@synthesize sensorValues;

- (id)init {
	self = [super initWithBeanType:RESULT];
    if (self) {
        self.sensorValues = [[NSMutableArray alloc] initWithCapacity:2];
    }
	
	return self;
}

- (void)fromXML:(NSXMLElement* )xml {
	NSArray* sensorValueElements = [xml children];
    
    for (NSXMLElement *sensorValuesElement in sensorValueElements) {
        SensorValue *sensorValue = [[SensorValue alloc] init];
        for (NSXMLElement *sensorValueElement in [sensorValuesElement children]) {
            [sensorValue setValue:[sensorValueElement stringValue] forKey:[sensorValueElement name]];
            [self.sensorValues addObject:sensorValue];
        }
        [self.sensorValues addObject:sensorValue];
    }
}

+ (NSString* )elementName {
	return @"DelegateSensorValues";
}

+ (NSString* )iqNamespace {
	return @"acdsense:iq:delegatesensorvalues";
}

@end