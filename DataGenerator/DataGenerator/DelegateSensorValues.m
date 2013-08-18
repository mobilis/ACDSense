#import "DelegateSensorValues.h"

@implementation DelegateSensorValues

@synthesize sensorValues;

- (id)init {
	self = [super initWithBeanType:RESULT];
	
	return self;
}

- (void)fromXML:(NSXMLElement* )xml {

}

+ (NSString* )elementName {
	return @"DelegateSensorValues";
}

+ (NSString* )iqNamespace {
	return @"acdsense:iq:delegatesensorvalues";
}

@end