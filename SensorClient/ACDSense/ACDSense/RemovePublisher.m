#import "RemovePublisher.h"

@implementation RemovePublisher

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
	return @"RemovePublisher";
}

+ (NSString* )iqNamespace {
	return @"acdsense:iq:removepublisher";
}

@end