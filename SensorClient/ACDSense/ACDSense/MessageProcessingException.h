//
// Created by Martin Weissbach on 3/11/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MessageProcessingException : NSException

+ (instancetype)exceptionWithError:(NSError *)error;

@end