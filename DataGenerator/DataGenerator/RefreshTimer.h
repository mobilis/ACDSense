//
//  RefreshTimer.h
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RefreshTimer : NSObject

@property (strong, nonatomic) id target;
@property (nonatomic) SEL selector;

- (id)initWithTarget:(id)target invokeMethod:(SEL)method;

- (void)stop;
- (void)restart;

@end
