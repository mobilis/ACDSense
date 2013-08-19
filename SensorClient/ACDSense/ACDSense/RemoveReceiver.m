#import "RemoveReceiver.h"

@implementation RemoveReceiver

- (id)init {
	self = [super initWithBeanType:SET];
	
	return self;
}

- (NSXMLElement* )toXML {
	NSXMLElement* beanElement = [NSXMLElement elementWithName:[[self class] elementName]
														xmlns:[[self class] iqNamespace]];

	return beanElement;
}

+ (NSString* )elementName {
	return @"RemoveReceiver";
}

+ (NSString* )iqNamespace {
	return @"acdsense:iq:removereceiver";
}

@end