//
// Created by Martin Weissbach on 2/25/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class XMPPJID;
@class Location;
@class SensorMUCDomain;

@interface SensorMUC : NSManagedObject

@property (nonatomic, readonly) NSString *jabberID;
@property (nonatomic, readonly) NSString *domainName;
@property (nonatomic, readonly) NSString *jsonDescription;

+ (instancetype)sensorMUCwithJabberID:(XMPPJID *)jabberID domainName:(NSString *)domainName andDescription:(NSString *)description;

- (id)initWithJabberID:(XMPPJID *)jabberID domainName:(NSString *)domainName andDescription:(NSString *)description;

- (SensorMUCDomain *)copyAsSensorMUCDomain;

- (NSString *)type;
- (Location *)location;

@end