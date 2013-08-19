//
//  SensorValue.h
//  DataGenerator
//
//  Created by Martin Weißbach on 8/18/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SensorValue : NSObject

@property (strong, nonatomic) NSString *value;
@property (strong, nonatomic) NSString *unit;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *location;

@end
