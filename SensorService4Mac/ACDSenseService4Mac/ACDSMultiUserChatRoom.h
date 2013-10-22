//
// Created by Martin Weißbach on 10/21/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "MXiMultiUserChatRoom.h"

@class Location;

@interface ACDSMultiUserChatRoom : MXiMultiUserChatRoom

@property (nonatomic) Location *sensorLocation;
@property (nonatomic) NSString *countryCode;
@property (nonatomic) NSString *type;

+ (ACDSMultiUserChatRoom *)roomWithMXiChatRoom:(MXiMultiUserChatRoom *)room andXFormElement:(NSXMLElement *)element;

- (id)initWithMXiChatRoom:(MXiMultiUserChatRoom *)room andXFormElement:(NSXMLElement *)element;

@end