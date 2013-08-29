#import "PublishSensorItems.h"

@implementation PublishSensorItems

- (id)init {
	self = [super initWithBeanType:SET];

	return self;
}

- (NSXMLElement* )toXML {
	NSXMLElement* beanElement = [NSXMLElement elementWithName:[[self class] elementName]
														xmlns:[[self class] iqNamespace]];

	for (SensorItem* sensorItemsPart in [self sensorItems]) {
		NSXMLElement* sensorItemsElement = [NSXMLElement elementWithName:@"sensorItems"];
		NSXMLElement* sensorIdElement = [NSXMLElement elementWithName:@"sensorId"];
		[sensorIdElement setStringValue:[sensorItemsPart sensorId]];
		[sensorItemsElement addChild:sensorIdElement];
		for (SensorValue* valuesPart in [sensorItemsPart values]) {
			NSXMLElement* valuesElement = [NSXMLElement elementWithName:@"values"];
			NSXMLElement* subTypeElement = [NSXMLElement elementWithName:@"subType"];
			[subTypeElement setStringValue:[valuesPart subType]];
			[valuesElement addChild:subTypeElement];
			NSXMLElement* valueElement = [NSXMLElement elementWithName:@"value"];
			[valueElement setStringValue:[valuesPart value]];
			[valuesElement addChild:valueElement];
			NSXMLElement* unitElement = [NSXMLElement elementWithName:@"unit"];
			[unitElement setStringValue:[valuesPart unit]];
			[valuesElement addChild:unitElement];
			NSXMLElement* timestampElement = [NSXMLElement elementWithName:@"timestamp"];
			NSXMLElement* dayElement = [NSXMLElement elementWithName:@"day"];
			[dayElement setStringValue:[NSString stringWithFormat:@"%d", [[valuesPart timestamp] day]]];
			[timestampElement addChild:dayElement];
			NSXMLElement* monthElement = [NSXMLElement elementWithName:@"month"];
			[monthElement setStringValue:[NSString stringWithFormat:@"%d", [[valuesPart timestamp] month]]];
			[timestampElement addChild:monthElement];
			NSXMLElement* yearElement = [NSXMLElement elementWithName:@"year"];
			[yearElement setStringValue:[NSString stringWithFormat:@"%d", [[valuesPart timestamp] year]]];
			[timestampElement addChild:yearElement];
			NSXMLElement* hourElement = [NSXMLElement elementWithName:@"hour"];
			[hourElement setStringValue:[NSString stringWithFormat:@"%d", [[valuesPart timestamp] hour]]];
			[timestampElement addChild:hourElement];
			NSXMLElement* minuteElement = [NSXMLElement elementWithName:@"minute"];
			[minuteElement setStringValue:[NSString stringWithFormat:@"%d", [[valuesPart timestamp] minute]]];
			[timestampElement addChild:minuteElement];
			NSXMLElement* secondElement = [NSXMLElement elementWithName:@"second"];
			[secondElement setStringValue:[NSString stringWithFormat:@"%d", [[valuesPart timestamp] second]]];
			[timestampElement addChild:secondElement];

			[valuesElement addChild:timestampElement];

			[sensorItemsElement addChild:valuesElement];
		}
		NSXMLElement* locationElement = [NSXMLElement elementWithName:@"location"];
		NSXMLElement* latitudeElement = [NSXMLElement elementWithName:@"latitude"];
		[latitudeElement setStringValue:[NSString stringWithFormat:@"%d", [[sensorItemsPart location] latitude]]];
		[locationElement addChild:latitudeElement];
		NSXMLElement* longitudeElement = [NSXMLElement elementWithName:@"longitude"];
		[longitudeElement setStringValue:[NSString stringWithFormat:@"%d", [[sensorItemsPart location] longitude]]];
		[locationElement addChild:longitudeElement];

		[sensorItemsElement addChild:locationElement];
		NSXMLElement* typeElement = [NSXMLElement elementWithName:@"type"];
		[typeElement setStringValue:[sensorItemsPart type]];
		[sensorItemsElement addChild:typeElement];

		[beanElement addChild:sensorItemsElement];
	}

	return beanElement;
}

+ (NSString* )elementName {
	return @"PublishSensorItems";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end