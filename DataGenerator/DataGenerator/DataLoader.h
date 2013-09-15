//
// Created by Martin Weißbach on 9/15/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@protocol DataLoaderDelegate

- (void)numberOfFiles:(NSUInteger)numberOfFiles inDirectory:(NSString *)directoryPath;

@end

@interface DataLoader : NSObject

@property (strong, nonatomic) NSString *directoryPath;

@property (weak, nonatomic) id<DataLoaderDelegate> delegate;

+ (id)loadWithDirectory:(NSString *)pathToDirectory;

- (id)initWithDirectory:(NSString *)pathToDirectory;

- (void)startLoading;
- (void)startLoadingNumberOfFiles:(NSUInteger)numberOfFiles;

@end