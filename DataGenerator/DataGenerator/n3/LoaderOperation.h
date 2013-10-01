//
// Created by Martin Weißbach on 9/16/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


@class SensorItem;

@interface LoaderOperation : NSOperation

- (id)initWithXMLString:(NSString *)xmlString;

- (SensorItem *)sensorItem;

@end