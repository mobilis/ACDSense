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
	[domainIdElement setStringValue:[self.domain domainId]];
	[domainElement addChild:domainIdElement];
	NSXMLElement* innerDomainElement = [NSXMLElement elementWithName:@"domain"];
	[innerDomainElement setStringValue:[self.domain domain]];
	[domainElement addChild:innerDomainElement];

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