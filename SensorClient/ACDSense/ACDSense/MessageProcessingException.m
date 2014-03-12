//
// Created by Martin Weissbach on 3/11/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import "MessageProcessingException.h"


@implementation MessageProcessingException

+ (instancetype)exceptionWithError:(NSError *)error
{
    return [[self alloc] initWithName:@"JSON – String invalid format"
                               reason:@"JSON string is invalid."
                             userInfo:error.userInfo];
}

@end