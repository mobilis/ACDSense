//
// Created by Martin Weissbach on 3/1/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SensorItem;


@interface MUCMessageProcessor : NSObject

+ (instancetype)processJSONString:(NSString *)jsonString;

- (SensorItem *)processedJSON;

@end