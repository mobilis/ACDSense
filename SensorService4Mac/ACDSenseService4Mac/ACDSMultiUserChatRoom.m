//
// Created by Martin Weißbach on 10/21/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import "ACDSMultiUserChatRoom.h"
#import "Location.h"

@implementation ACDSMultiUserChatRoom

+ (ACDSMultiUserChatRoom *)roomWithMXiChatRoom:(MXiMultiUserChatRoom *)room andXFormElement:(NSXMLElement *)element
{
    return [[self alloc] initWithMXiChatRoom:room andXFormElement:element];
}

- (id)initWithMXiChatRoom:(MXiMultiUserChatRoom *)room andXFormElement:(NSXMLElement *)element
{
    self = [super initWithName:room.name jabberID:room.jabberID];
    if (self) {
        NSError *error = nil;
        NSArray *descriptionNodes = [element nodesForXPath:@"//field[@var='muc#roominfo_description'"
                                                     error:&error];
        if (error || descriptionNodes.count == 0) {
            // TODO: implement error handling for XPath reading here
        }
        [self parseJSON:[((NSXMLNode *)descriptionNodes[0]) childAtIndex:0]];
    }

    return self;
}

- (void)parseJSON:(NSXMLNode *)node
{
    NSString *jsonString = [node stringValue];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0
                                                      error:&error];
    if (error || ![jsonObject isKindOfClass:[NSDictionary class]]) {
        // TODO: implement error handling for JSON parsing.
    }

    self.type = [jsonObject valueForKeyPath:@"sensormuc.type"];

    id location = [jsonObject valueForKeyPath:@"sensormuc.location"];
    self.countryCode = [location valueForKey:@"countryCode"];
    self.sensorLocation = [[Location alloc] init];
    self.sensorLocation.locationName = [location valueForKey:@"cityName"];
    self.sensorLocation.latitude = [[location valueForKey:@"latitude"] floatValue];
    self.sensorLocation.longitude = [[location valueForKey:@"longitude"] floatValue];
}
@end