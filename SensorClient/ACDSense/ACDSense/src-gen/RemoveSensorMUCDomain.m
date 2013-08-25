#import "RemoveSensorMUCDomain.h"

@implementation RemoveSensorMUCDomain

- (id)init {
	self = [super initWithBeanType:SET];

	return self;
}

- (NSXMLElement* )toXML {
	NSXMLElement* beanElement = [NSXMLElement elementWithName:[[self class] elementName]
														xmlns:[[self class] iqNamespace]];

	NSXMLElement* domainElement = [NSXMLElement elementWithName:@"domain"];
	NSXMLElement* domainIdElement = [NSXMLElement elementWithName:@"domainId"];
	[domainIdElement setStringValue:[domain domainId]];
	[domainElement addChild:domainIdElement];
	NSXMLElement* domainElement = [NSXMLElement elementWithName:@"domain"];
	[domainElement setStringValue:[domain domain]];
	[domainElement addChild:domainElement];

	[beanElement addChild:domainElement];

	return beanElement;
}

+ (NSString* )elementName {
	return @"RemoveSensorMUCDomain";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end