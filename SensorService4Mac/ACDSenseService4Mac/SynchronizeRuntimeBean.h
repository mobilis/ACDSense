//
// Created by Martin Weißbach on 10/24/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MobilisMXi/MXi/MXiIncomingBean.h>
#import "MXiBean.h"
#import "MXiOutgoingBean.h"


@interface SynchronizeRuntimeBean : MXiBean <MXiOutgoingBean, MXiIncomingBean>

@property (nonatomic) NSArray *serviceJIDs;
@property BOOL successfullyAddedService;

- (id)initWithTargetRuntimeJID:(NSString *)jabberID;
- (id)initWithServiceJIDs:(NSArray *)serviceJIDs;

@end