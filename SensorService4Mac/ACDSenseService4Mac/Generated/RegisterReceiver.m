#import "RegisterReceiver.h"

@implementation RegisterReceiver

- (id)init {
	self = [super initWithBeanType:SET];

	return self;
}

- (NSXMLElement* )toXML {
	NSXMLElement* beanElement = [NSXMLElement elementWithName:[[self class] elementName]
														xmlns:[[self class] iqNamespace]];

	return beanElement;
}

- (void)fromXML:(NSXMLElement *)xml
{
    // Can probably remain empty.
}

+ (NSString* )elementName {
	return @"RegisterReceiver";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end