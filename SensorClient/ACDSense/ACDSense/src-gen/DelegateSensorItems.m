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
			NSXMLElement* timestampElement = [valuesElement elementForName:@"timestamp"];
			[valuesObject setTimestamp:[[Timestamp alloc] init]];
			NSXMLElement* dayElement = [timestampElement elementForName:@"day"];
			[[valuesObject timestamp] setDay:[[dayElement stringValue] integerValue]];
			NSXMLElement* monthElement = [timestampElement elementForName:@"month"];
			[[valuesObject timestamp] setMonth:[[monthElement stringValue] integerValue]];
			NSXMLElement* yearElement = [timestampElement elementForName:@"year"];
			[[valuesObject timestamp] setYear:[[yearElement stringValue] integerValue]];
			NSXMLElement* hourElement = [timestampElement elementForName:@"hour"];
			[[valuesObject timestamp] setHour:[[hourElement stringValue] integerValue]];
			NSXMLElement* minuteElement = [timestampElement elementForName:@"minute"];
			[[valuesObject timestamp] setMinute:[[minuteElement stringValue] integerValue]];
			NSXMLElement* secondElement = [timestampElement elementForName:@"second"];
			[[valuesObject timestamp] setSecond:[[secondElement stringValue] integerValue]];
			[[sensorItemsObject values] addObject:valuesObject];
		}
		NSXMLElement* locationElement = [sensorItemsElement elementForName:@"location"];
		[sensorItemsObject setLocation:[[Location alloc] init]];
		NSXMLElement* latitudeElement = [locationElement elementForName:@"latitude"];
		[[sensorItemsObject location] setLatitude:[[latitudeElement stringValue] integerValue]];
		NSXMLElement* longitudeElement = [locationElement elementForName:@"longitude"];
		[[sensorItemsObject location] setLongitude:[[longitudeElement stringValue] integerValue]];
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