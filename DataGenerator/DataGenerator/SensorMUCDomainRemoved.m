#import "SensorMUCDomainRemoved.h"

@implementation SensorMUCDomainRemoved

- (id)init {
	self = [super initWithBeanType:RESULT];

	return self;
}

- (void)fromXML:(NSXMLElement* )xml {
	NSXMLElement* sensorDomainElement = [xml elementForName:@"sensorDomain"];
	[self setSensorDomain:[[SensorMUCDomain alloc] init]];
	NSXMLElement* domainIdElement = [sensorDomainElement elementForName:@"domainId"];
	[[self sensorDomain] setDomainId:[domainIdElement stringValue]];
	NSXMLElement* domainURLElement = [sensorDomainElement elementForName:@"domainURL"];
	[[self sensorDomain] setDomainURL:[domainURLElement stringValue]];
}

+ (NSString* )elementName {
	return @"SensorMUCDomainRemoved";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end