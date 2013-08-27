#import "DelegateSensorItems.h"

@implementation DelegateSensorItems

- (id)init {
	self = [super initWithBeanType:RESULT];

	return self;
}

- (void)fromXML:(NSXMLElement* )xml {
	[self setSensorItems:[NSMutableArray array]];
	NSArray* sensorItemsElements = [xml elementsForName:@"sensorItems"];
	for (NSXMLElement* sensorItemsElement in sensorItemsElements) {
		SensorItem *sensorItemsObject = [[SensorItem alloc] init];
		NSXMLElement* sensorIdElement = [sensorItemsElement elementForName:@"sensorId"];
		[sensorItemsObject setSensorId:[sensorIdElement stringValue]];
		[sensorItemsObject setValues:[NSMutableArray array]];
		NSArray* valuesElements = [sensorItemsElement elementsForName:@"values"];
		for (NSXMLElement* valuesElement in valuesElements) {
			SensorValue *valuesObject = [[SensorValue alloc] init];
			NSXMLElement* subTypeElement = [valuesElement elementForName:@"subType"];
			[valuesObject setSubType:[subTypeElement stringValue]];
			NSXMLElement* valueElement = [valuesElement elementForName:@"value"];
			[valuesObject setValue:[valueElement stringValue]];
			NSXMLElement* unitElement = [valuesElement elementForName:@"unit"];
			[valuesObject setUnit:[unitElement stringValue]];
			[[sensorItemsObject values] addObject:valuesObject];
		}
		NSXMLElement* locationElement = [sensorItemsElement elementForName:@"location"];
		[sensorItemsObject setLocation:[locationElement stringValue]];
		NSXMLElement* typeElement = [sensorItemsElement elementForName:@"type"];
		[sensorItemsObject setType:[typeElement stringValue]];
		[[self sensorItems] addObject:sensorItemsObject];
	}
}

+ (NSString* )elementName {
	return @"DelegateSensorItems";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end