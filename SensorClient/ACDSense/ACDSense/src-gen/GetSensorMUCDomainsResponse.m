#import "GetSensorMUCDomainsResponse.h"

@implementation GetSensorMUCDomainsResponse

- (id)init {
	self = [super initWithBeanType:RESULT];

	return self;
}

- (void)fromXML:(NSXMLElement* )xml {
	[self setSensorDomains:[NSMutableArray array]];
	NSArray* sensorDomainsElements = [xml elementsForName:@"sensorDomains"];
	for (NSXMLElement* sensorDomainsElement in sensorDomainsElements) {
		SensorMUCDomain *sensorDomainsObject = [[SensorMUCDomain alloc] init];
		NSXMLElement* domainIdElement = [sensorDomainsElement elementForName:@"domainId"];
		[sensorDomainsObject setDomainId:[domainIdElement stringValue]];
		NSXMLElement* domainURLElement = [sensorDomainsElement elementForName:@"domainURL"];
		[sensorDomainsObject setDomainURL:[domainURLElement stringValue]];
		[[self sensorDomains] addObject:sensorDomainsObject];
	}
}

+ (NSString* )elementName {
	return @"GetSensorMUCDomainsResponse";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end