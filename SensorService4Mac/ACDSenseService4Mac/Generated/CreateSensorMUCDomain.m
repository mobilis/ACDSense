#import "CreateSensorMUCDomain.h"

@implementation CreateSensorMUCDomain

- (id)init {
	self = [super initWithBeanType:SET];

	return self;
}

- (NSXMLElement* )toXML {
	NSXMLElement* beanElement = [NSXMLElement elementWithName:[[self class] elementName]
														xmlns:[[self class] iqNamespace]];

	NSXMLElement* sensorDomainElement = [NSXMLElement elementWithName:@"sensorDomain"];
	NSXMLElement* domainIdElement = [NSXMLElement elementWithName:@"domainId"];
	[domainIdElement setStringValue:[[self sensorDomain] domainId]];
	[sensorDomainElement addChild:domainIdElement];
	NSXMLElement* domainURLElement = [NSXMLElement elementWithName:@"domainURL"];
	[domainURLElement setStringValue:[[self sensorDomain] domainURL]];
	[sensorDomainElement addChild:domainURLElement];

	[beanElement addChild:sensorDomainElement];

	return beanElement;
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
	return @"CreateSensorMUCDomain";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end