//
//  ValueCalculator.m
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "ValueCalculator.h"

#define UPPER_LIMIT 40.0
#define LOWER_LIMIT -20.0
#define STEPS 20

@interface ValueCalculator ()

@property (nonatomic) BOOL ascending;
@property (nonatomic) int stepCount;

- (void)initCalculation;

@end

@implementation ValueCalculator

#pragma mark - Initialize

- (id)init
{
    self = [super init];
    if (self) {
        _upperLimit = UPPER_LIMIT;
        _lowerLimit = LOWER_LIMIT;
        _intermediarySteps = STEPS;
        [self initCalculation];
    }
    return self;
}

- (id)initWithUpperLimit:(float)upperLimit lowerLimit:(float)lowerLimit intermediarySteps:(int)steps
{
    self = [super init];
    if (self) {
        if (upperLimit > lowerLimit) {
            _upperLimit = upperLimit;
            _lowerLimit = lowerLimit;
        } else {
            _upperLimit = UPPER_LIMIT;
            _lowerLimit = LOWER_LIMIT;
        }
        _intermediarySteps = (steps > 0) ? steps : STEPS;
        [self initCalculation];
    }
    return self;
}

- (void)initCalculation
{
    _ascending = YES;
    _stepCount = 0;
}

#pragma mark - Calculate Temp Value

- (NSNumber *)nextValue
{
    float difference = (_upperLimit - _lowerLimit) / _intermediarySteps;
    float stepValue = difference * ++_stepCount;
    
    NSNumber *nextValue = nil;
    if (_ascending) {
        nextValue = [NSNumber numberWithFloat:_lowerLimit + stepValue];
    } else {
        nextValue = [NSNumber numberWithFloat:_upperLimit - stepValue];
    }
    
    if (_stepCount == _intermediarySteps) {
        _ascending = !_ascending;
        _stepCount = 0;
    }
    
    return nextValue;
}

@end
