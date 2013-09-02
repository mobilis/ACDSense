#import "GetSensorMUCDomainsRequest.h"

@implementation GetSensorMUCDomainsRequest

- (id)init {
	self = [super initWithBeanType:GET];

	return self;
}

- (NSXMLElement* )toXML {
	NSXMLElement* beanElement = [NSXMLElement elementWithName:[[self class] elementName]
														xmlns:[[self class] iqNamespace]];

	return beanElement;
}

+ (NSString* )elementName {
	return @"GetSensorMUCDomainsRequest";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end