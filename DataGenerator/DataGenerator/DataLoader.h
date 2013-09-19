//
// Created by Martin Weißbach on 9/15/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class SensorItem;


@protocol DataLoaderDelegate

- (void)numberOfFiles:(NSUInteger)numberOfFiles inDirectory:(NSString *)directoryPath;
- (void)sensorItemParsed:(SensorItem *)sensorItem;
- (void)loadingFinished:(BOOL)successfull;

@end

/**
*   The class loads files from a given directory asynchronously into memory.
*   In this project it is used to read the weather-xml files from a specified directory.
*/
@interface DataLoader : NSObject

@property (strong, nonatomic) NSString *directoryPath;

@property (weak, nonatomic) id<DataLoaderDelegate> delegate;


/**
* Returns a new DataLoader instance.
*
* @param pathToDirectory The path to the directory where data files should be read from.
*
* @return A new DataLoader instance.
*/
+ (id)loadWithDirectory:(NSString *)pathToDirectory;
- (id)initWithDirectory:(NSString *)pathToDirectory;

/**
*   Start loading files from the directory this instance was created with.
*   This method executes asynchronously and data is delivered via invoking delegate methods.
*
*   @param numberOfFiles A number of files that should be read. If zero or not specified, all files in the directory are read.
*/
- (void)startLoading;
- (void)startLoadingNumberOfFiles:(NSUInteger)numberOfFiles;

- (void)stopLoading;

@end