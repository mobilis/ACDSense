//
//  DelegateSelectorMapping.h
//  ACDSense
//
//  Created by Martin Weißbach on 8/25/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MXi/MXiBean.h>
#import <MXi/MXiIncomingBean.h>

@interface DelegateSelectorMapping : NSObject

@property (strong, nonatomic) id delegate;
@property SEL selector;

- (id)initWithDelegate:(id)delegate andSelector:(SEL)selector;

@end
