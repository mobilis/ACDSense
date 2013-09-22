//
//  MUCInformation.h
//  DataGenerator
//
//  Created by Martin Weißbach on 9/3/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ValueCalculator.h"

@interface MUCInformation : NSObject <ValueCalculatorProtocol>

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *type;
@property float lowerLimit;
@property float upperLimit;
@property int intermediarySteps;

@property (nonatomic, copy) NSString *sensorID;

//- (id)initWithAddress:(NSString *)address type:(NSString *)type;
//- (id)initWithAddress:(NSString *)address type:(NSString *)type lowerLimit:(float)lowerLimit upperLimit:(float)upperLimit;
//- (id)initWithAddress:(NSString *)address type:(NSString *)type lowerLimit:(float)lowerLimit upperLimit:(float)upperLimit intermediarySteps:(int)steps;

- (id)initWithAddress:(NSString *)address andSensorID:(NSString *)sensorID;

@end
