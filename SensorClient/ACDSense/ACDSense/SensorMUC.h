//
// Created by Martin Weissbach on 2/25/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPJID;
@class Location;
@class SensorMUCDomain;

@interface SensorMUC : NSObject

@property (nonatomic, readonly) XMPPJID *jabberID;
@property (nonatomic, readonly) NSString *domainName;

- (id)initWithJabberID:(XMPPJID *)jabberID domainName:(NSString *)domainName andDescription:(NSString *)description;

- (SensorMUCDomain *)copyAsSensorMUCDomain;

- (NSString *)type;
- (Location *)location;

@end