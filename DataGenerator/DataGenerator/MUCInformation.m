//
//  MUCInformation.m
//  DataGenerator
//
//  Created by Martin Weißbach on 9/3/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "MUCInformation.h"

@interface MUCInformation ()

@property (strong, nonatomic) ValueCalculator *valueCalculator;
@property (strong, nonatomic) NSString *valueUnit;

- (void)setupValueCalculator;
- (void)setUpUnit;

@end

@implementation MUCInformation

- (id)initWithAddress:(NSString *)address type:(NSString *)type
{
    return [self initWithAddress:address type:type lowerLimit:0.0 upperLimit:0.0 intermediarySteps:0];
}

- (id)initWithAddress:(NSString *)address type:(NSString *)type lowerLimit:(float)lowerLimit upperLimit:(float)upperLimit
{
    return [self initWithAddress:address type:type lowerLimit:lowerLimit upperLimit:upperLimit intermediarySteps:0];
}

- (id)initWithAddress:(NSString *)address type:(NSString *)type lowerLimit:(float)lowerLimit upperLimit:(float)upperLimit intermediarySteps:(int)steps
{
    self = [super init];
    if (self) {
        _address = address;
        _type = type;
        _lowerLimit = lowerLimit;
        _upperLimit = upperLimit;
        _intermediarySteps = steps;
        
        [self setupValueCalculator];
    }
    return self;
}

- (void)setupValueCalculator
{
    self.valueCalculator = [[ValueCalculator alloc] initWithUpperLimit:_upperLimit lowerLimit:_lowerLimit intermediarySteps:_intermediarySteps];
}

- (void)setUpUnit
{
    if ([_type compare:@"temperature" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        self.valueUnit = @"Celsius";
    }
    if ([_type compare:@"humidity" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        self.valueUnit = @"%";
    }
    if ([_type compare:@"athmosphericpressure" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        self.valueUnit = @"hPa";
    }
    if ([_type compare:@"wind" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        self.valueUnit = @"km/h";
    }
}

#pragma mark - ValueCalculatorProtocol

- (NSNumber *)nextValue
{
    return [_valueCalculator nextValue];
}

- (NSString *)unitOfValues
{
    return _valueUnit;
}

@end
