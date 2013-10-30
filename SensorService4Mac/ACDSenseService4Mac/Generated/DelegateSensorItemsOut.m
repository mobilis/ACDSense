#import "DelegateSensorItemsOut.h"

@implementation DelegateSensorItemsOut

- (id)init {
	self = [super initWithBeanType:RESULT];

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
		NSXMLElement* sensorDescriptionElement = [NSXMLElement elementWithName:@"sensorDescription"];
		[sensorDescriptionElement setStringValue:[sensorItemsPart sensorDescription]];
		[sensorItemsElement addChild:sensorDescriptionElement];
		NSXMLElement* sensorDomainElement = [NSXMLElement elementWithName:@"sensorDomain"];
		NSXMLElement* domainIdElement = [NSXMLElement elementWithName:@"domainId"];
		[domainIdElement setStringValue:[[sensorItemsPart sensorDomain] domainId]];
		[sensorDomainElement addChild:domainIdElement];
		NSXMLElement* domainURLElement = [NSXMLElement elementWithName:@"domainURL"];
		[domainURLElement setStringValue:[[sensorItemsPart sensorDomain] domainURL]];
		[sensorDomainElement addChild:domainURLElement];

		[sensorItemsElement addChild:sensorDomainElement];
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
			[dayElement setStringValue:[NSString stringWithFormat:@"%li", [[valuesPart timestamp] day]]];
			[timestampElement addChild:dayElement];
			NSXMLElement* monthElement = [NSXMLElement elementWithName:@"month"];
			[monthElement setStringValue:[NSString stringWithFormat:@"%li", [[valuesPart timestamp] month]]];
			[timestampElement addChild:monthElement];
			NSXMLElement* yearElement = [NSXMLElement elementWithName:@"year"];
			[yearElement setStringValue:[NSString stringWithFormat:@"%li", [[valuesPart timestamp] year]]];
			[timestampElement addChild:yearElement];
			NSXMLElement* hourElement = [NSXMLElement elementWithName:@"hour"];
			[hourElement setStringValue:[NSString stringWithFormat:@"%li", [[valuesPart timestamp] hour]]];
			[timestampElement addChild:hourElement];
			NSXMLElement* minuteElement = [NSXMLElement elementWithName:@"minute"];
			[minuteElement setStringValue:[NSString stringWithFormat:@"%li", [[valuesPart timestamp] minute]]];
			[timestampElement addChild:minuteElement];
			NSXMLElement* secondElement = [NSXMLElement elementWithName:@"second"];
			[secondElement setStringValue:[NSString stringWithFormat:@"%li", [[valuesPart timestamp] second]]];
			[timestampElement addChild:secondElement];

			[valuesElement addChild:timestampElement];

			[sensorItemsElement addChild:valuesElement];
		}
		NSXMLElement* locationElement = [NSXMLElement elementWithName:@"location"];
		NSXMLElement* latitudeElement = [NSXMLElement elementWithName:@"latitude"];
		[latitudeElement setStringValue:[NSString stringWithFormat:@"%f", [[sensorItemsPart location] latitude]]];
		[locationElement addChild:latitudeElement];
		NSXMLElement* longitudeElement = [NSXMLElement elementWithName:@"longitude"];
		[longitudeElement setStringValue:[NSString stringWithFormat:@"%f", [[sensorItemsPart location] latitude]]];
		[locationElement addChild:longitudeElement];
		NSXMLElement* locationNameElement = [NSXMLElement elementWithName:@"locationName"];
		[locationNameElement setStringValue:[[sensorItemsPart location] locationName]];
		[locationElement addChild:locationNameElement];

		[sensorItemsElement addChild:locationElement];
		NSXMLElement* typeElement = [NSXMLElement elementWithName:@"type"];
		[typeElement setStringValue:[sensorItemsPart type]];
		[sensorItemsElement addChild:typeElement];

		[beanElement addChild:sensorItemsElement];
	}

	return beanElement;
}

+ (NSString* )elementName {
	return @"DelegateSensorItems";
}

+ (NSString* )iqNamespace {
	return @"http://mobilis.inf.tu-dresden.de/ACDSense";
}

@end