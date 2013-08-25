#import "GetSensorMUCDomainsResponse.h"

@implementation GetSensorMUCDomainsResponse

- (id)init {
	self = [super initWithBeanType:RESULT];

	return self;
}

- (void)fromXML:(NSXMLElement* )xml {
	[self setDomains:[NSMutableArray array]];
	NSArray* domainsElements = [xml elementsForName:@"domains"];
	for (NSXMLElement* domainsElement in domainsElements) {
		domainsObject = [[SensorMUCDomain alloc] init];
		NSXMLElement* domainIdElement = [domainsElement elementForName:@"domainId"];
		[domainsObject setDomainId:[domainIdElement stringValue]];
		NSXMLElement* domainElement = [domainsElement elementForName:@"domain"];
		[domainsObject setDomain:[domainElement stringValue]];
		[[self domains] addObject:domainsObject];
	}
}

+ (NSString* )elementName {
	return @"GetSensorMUCDomainsResponse";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end