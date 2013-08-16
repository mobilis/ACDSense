#import "DelegateSensorValues.h"

@implementation DelegateSensorValues

@synthesize sensorValues;

- (id)init {
	self = [super initWithBeanType:RESULT];
	
	return self;
}

- (void)fromXML:(NSXMLElement* )xml {
	NSXMLElement* sensorValuesElement = (NSXMLElement*) [xml childAtIndex:0];
}

+ (NSString* )elementName {
	return @"DelegateSensorValues";
}

+ (NSString* )iqNamespace {
	return @"acdsense:iq:delegatesensorvalues";
}

@end