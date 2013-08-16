#import "RegisterReceiver.h"

@implementation RegisterReceiver

@synthesize ;

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
	return @"RegisterReceiver";
}

+ (NSString* )iqNamespace {
	return @"acdsense:iq:registerreceiver";
}

@end