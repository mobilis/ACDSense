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
	NSXMLElement* domainElement = [domainElement elementForName:@"domain"];
	[[self domain] setDomain:[domainElement stringValue]];
}

+ (NSString* )elementName {
	return @"SensorMUCDomainCreated";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end