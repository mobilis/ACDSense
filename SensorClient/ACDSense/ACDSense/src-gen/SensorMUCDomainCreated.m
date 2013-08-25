#import "SensorMUCDomainCreated.h"

@implementation SensorMUCDomainCreated

- (id)init {
	self = [super initWithBeanType:RESULT];

	return self;
}

- (void)fromXML:(NSXMLElement* )xml {
	NSXMLElement* domainElement = [xml elementForName:@"domain"];
	[self setDomain:[[SensorMUCDomain alloc] init]];
	NSXMLElement* domainIdElement = [domainElement elementForName:@"domainId"];
	[[self domain] setDomainId:[domainIdElement stringValue]];
	NSXMLElement* innerDomainElement = [domainElement elementForName:@"domain"];
	[[self domain] setDomain:[innerDomainElement stringValue]];
}

+ (NSString* )elementName {
	return @"SensorMUCDomainCreated";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end