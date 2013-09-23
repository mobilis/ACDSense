//
// Created by Martin Weißbach on 9/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "DataLoader.h"

@class SensorValue;

@protocol DataHandlerDelegate

- (void)sendSensorValue:(SensorValue *)sensorValue forSensorID:(NSString *)sensorID;

@end

/**
*   This class encapsulates the loading of files in a given directory and the propagation
*   of the respective objects gained by reading the files located in the given directory.
*/
@interface DataHandler : NSObject <DataLoaderDelegate>

@property (nonatomic, weak) id delegate;

@property (nonatomic) BOOL submitData;

@property (nonatomic, strong) DataLoader *dataLoader;

/**
*   Initialize a new instance of a DataHandler class.
*
*   @param delegate A delegate that should be called when certain events occur.
*   @param directory The directory where files to read are located in.
*
*   @return A new DataHandler instance configured with the given attributes.
*/
+ (id)dataHandlerWithDelegate:(id)delegate andDirectory:(NSString *)directory;
- (id)initWithDelegate:(id)delegate andDirectory:(NSString *)directory;

/**
*   Start loading the files in the directory.
*   This method executes asynchronously and results are delivered via the delegate.
*/
- (void)startLoading;

@end