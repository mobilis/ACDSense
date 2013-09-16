//
// Created by Martin Weißbach on 9/15/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DataLoader.h"
#import "LoaderOperation.h"
#import "NSString+FileReading.h"
#import "SensorItem.h"


@interface DataLoader ()

@property (nonatomic, strong) NSArray *dataFiles;
@property (atomic, strong) NSMutableArray *sensorItems;

@property (strong, nonatomic) NSOperationQueue *backgroundQueue;

@end

@implementation DataLoader

+ (id)loadWithDirectory:(NSString *)pathToDirectory
{
    return [[self alloc] initWithDirectory:pathToDirectory];
}

- (id)initWithDirectory:(NSString *)pathToDirectory
{
    self = [super init];
    if (self) {
        self.directoryPath = pathToDirectory;
        self.backgroundQueue = [NSOperationQueue new];
    }

    return self;
}

#pragma mark - KVO Compliance

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isFinished"]) {
        SensorItem *sensorItem = [((LoaderOperation *)object) sensorItem];
        @synchronized (_sensorItems) {
            [_sensorItems addObject:sensorItem];
        }
        [_delegate sensorItemParsed:sensorItem];
    }
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

    for (int i = 0; i < filesToLoad; i++) {
        NSOperation *dataLoader = [[LoaderOperation alloc] initWithXMLString:[NSString contentsOfFile:_dataFiles[i]]];
        [dataLoader addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:nil];
        [_backgroundQueue addOperation:dataLoader];
    }
}

@end