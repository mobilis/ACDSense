//
//  DelegateSelectorMapping.m
//  ACDSense
//
//  Created by Martin Weißbach on 8/25/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "DelegateSelectorMapping.h"

@implementation DelegateSelectorMapping

- (id)initWithDelegate:(id)delegate andSelector:(SEL)selector
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.selector = selector;
    }
    
    return self;
}

@end
