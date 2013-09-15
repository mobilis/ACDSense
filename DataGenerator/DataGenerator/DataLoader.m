//
// Created by Martin Weißbach on 9/15/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DataLoader.h"


@interface DataLoader ()

@property(nonatomic, strong) NSArray *dataFiles;

@end

@implementation DataLoader
{

}
+ (id)loadWithDirectory:(NSString *)pathToDirectory
{
    return [[self alloc] initWithDirectory:pathToDirectory];
}

- (id)initWithDirectory:(NSString *)pathToDirectory
{
    self = [super init];
    if (self) {
        self.directoryPath = pathToDirectory;
    }

    return self;
}

#pragma mark - Handle Data Loading

- (void)startLoading
{
    [self startLoadingNumberOfFiles:0];
}
- (void)startLoadingNumberOfFiles:(NSUInteger)numberOfFiles
{
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_directoryPath error:nil];
    if (!directoryContent || directoryContent.count == 0)
        return;

    NSMutableArray *xmlFiles = [NSMutableArray arrayWithCapacity:directoryContent.count];
    for (NSString *filename in directoryContent)
        if ([filename rangeOfString:@".xml"].location != NSNotFound)
            [xmlFiles addObject:filename];

    self.dataFiles = [NSArray arrayWithArray:xmlFiles];
    [self.delegate numberOfFiles:_dataFiles.count inDirectory:_directoryPath];

    [self dispatchDataLoadingWithNumberOfFiles:numberOfFiles];
}
- (void)dispatchDataLoadingWithNumberOfFiles:(NSUInteger)numberOfFiles
{
    NSUInteger filesToLoad = numberOfFiles;
    if (numberOfFiles == 0)
        filesToLoad = _dataFiles.count;

    // TODO: dispatch file loading and parsing
}

@end