//
// Created by Martin Weißbach on 9/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "DataLoader.h"

@protocol DataHandlerDelegate

- (void)sendSensorItem:(SensorItem *)sensorItem;

@end

@interface DataHandler : NSObject <DataLoaderDelegate>

@property (nonatomic, weak) id delegate;

@property (nonatomic) BOOL submitData;

@property (nonatomic, strong) DataLoader *dataLoader;

+ (id)dataHandlerWithDelegate:(id)delegate andDirectory:(NSString *)directory;

- (id)initWithDelegate:(id)delegate andDirectory:(NSString *)directory;

- (void)startLoading;
@end