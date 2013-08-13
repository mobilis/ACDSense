//
//  TempValueCalculator.h
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempValueCalculator : NSObject

@property (nonatomic, readonly) float upperLimit;
@property (nonatomic, readonly) float lowerLimit;
@property (nonatomic, readonly) int intermediarySteps;

- (id)initWithUpperLimit:(float)upperLimit lowerLimit:(float)lowerLimit intermediarySteps:(int)steps;

- (NSNumber *)nextValue;

@end
