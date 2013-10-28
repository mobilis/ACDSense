//
// Created by Martin Weißbach on 10/28/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import <Foundation/Foundation.h>

@class SensorMUCDomain;


@interface DomainStore : NSObject

@property (strong) NSArray *registeredDomains;

- (void)addDomain:(SensorMUCDomain *)domain;

- (void)removeDomain:(SensorMUCDomain *)domain;
@end