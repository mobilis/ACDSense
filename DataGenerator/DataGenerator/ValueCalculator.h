//
//  ValueCalculator.h
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ValueCalculatorProtocol <NSObject>

- (NSNumber *)nextValue;
- (NSString *)unitOfValues;

@end

@interface ValueCalculator : NSObject

@property (nonatomic, readonly) float upperLimit;
@property (nonatomic, readonly) float lowerLimit;
@property (nonatomic, readonly) int intermediarySteps;

- (id)initWithUpperLimit:(float)upperLimit lowerLimit:(float)lowerLimit intermediarySteps:(int)steps;

- (NSNumber *)nextValue;

@end
