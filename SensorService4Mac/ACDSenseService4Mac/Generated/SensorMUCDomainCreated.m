#import "SensorMUCDomainCreated.h"

#import "NSXMLElement+XMPP.h"

@implementation SensorMUCDomainCreated

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

- (NSXMLElement *)toXML
{
    NSXMLElement* sensorDomainElement = [NSXMLElement elementWithName:@"sensorDomain"];

    NSXMLElement* domainIdElement = [NSXMLElement elementWithName:@"domainId" stringValue:self.sensorDomain.domainId];
    NSXMLElement* domainURLElement = [NSXMLElement elementWithName:@"domainURL" stringValue:self.sensorDomain.domainURL];

    [sensorDomainElement addChild:domainIdElement];
    [sensorDomainElement addChild:domainURLElement];

    NSXMLElement *sensorDomainBean = [NSXMLElement elementWithName:[[self class] elementName] xmlns:[[self class] iqNamespace]];
    [sensorDomainBean addChild:sensorDomainElement];

    return sensorDomainBean;
}

+ (NSString* )elementName {
	return @"SensorMUCDomainCreated";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end