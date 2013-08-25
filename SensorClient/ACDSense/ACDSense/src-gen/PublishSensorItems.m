#import "PublishSensorItems.h"

@implementation PublishSensorItems

- (id)init {
	self = [super initWithBeanType:SET];

	return self;
}

- (NSXMLElement* )toXML {
	NSXMLElement* beanElement = [NSXMLElement elementWithName:[[self class] elementName]
														xmlns:[[self class] iqNamespace]];

	for (SensorItem* sensorItemsPart in sensorItems) {
		NSXMLElement* sensorItemsElement = [NSXMLElement elementWithName:@"sensorItems"];
		NSXMLElement* sensorIdElement = [NSXMLElement elementWithName:@"sensorId"];
		[sensorIdElement setStringValue:[sensorItemsPart sensorId]];
		[sensorItemsElement addChild:sensorIdElement];
		for (SensorValue* valuesPart in values) {
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

			[sensorItemsElement addChild:valuesElement];
		}
		NSXMLElement* locationElement = [NSXMLElement elementWithName:@"location"];
		[locationElement setStringValue:[sensorItemsPart location]];
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