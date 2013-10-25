//
// Created by Martin Weißbach on 10/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface ServerComponent : NSObject

+ (instancetype)sharedInstance;

- (id)initUniqueInstance;

- (void)synchronizeRuntimes;

@end