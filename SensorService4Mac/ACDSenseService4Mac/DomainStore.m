//
// Created by Martin Weißbach on 10/28/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import "DomainStore.h"
#import "SensorMUCDomain.h"

@interface DomainStore ()

- (void)initializeDomainListIfNotExisting;

@end

@implementation DomainStore

- (void)addDomain:(SensorMUCDomain *)domain
{
    if (!domain)
        return;

    [self initializeDomainListIfNotExisting];

    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.registeredDomains];
    [tempArray addObject:domain];
    self.registeredDomains = [NSArray arrayWithArray:tempArray];
}

- (void)initializeDomainListIfNotExisting
{
    if (self.registeredDomains == nil)
        self.registeredDomains = [NSArray array];
}

- (void)removeDomain:(SensorMUCDomain *)domain
{
    if (!domain)
        return;

    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.registeredDomains];
    [tempArray removeObject:domain];
    self.registeredDomains = [NSArray arrayWithArray:tempArray];
}

@end