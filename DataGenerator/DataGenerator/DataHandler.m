//
// Created by Martin Weißbach on 9/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DataHandler.h"
#import "SensorItem.h"

@interface DataHandler ()

@property (strong) NSMutableArray *cachedItems;

@end

@implementation DataHandler

+ (id)dataHandlerWithDelegate:(id)delegate andDirectory:(NSString *)directory
{
    return [[self alloc] initWithDelegate:delegate andDirectory:directory];
}

- (id)initWithDelegate:(id)delegate andDirectory:(NSString *)directory
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.dataLoader = [DataLoader loadWithDirectory:directory];
        self.dataLoader.delegate = self;
        self.cachedItems = [NSMutableArray arrayWithCapacity:50];
        self.submitData = NO;
    }
    
    return self;
}

#pragma mark - Custom Getter & Setter

- (void)setSubmitData:(BOOL)submitData
{
    if (_submitData == submitData)
        return;

    _submitData = submitData;
    if (_submitData)
        [self flushCachedItems];
}
- (void)flushCachedItems
{
    for (SensorItem *item in _cachedItems)
        if ([_delegate respondsToSelector:@selector(sendSensorItem:)])
            [_delegate performSelector:@selector(sendSensorItem:) withObject:item];
}

#pragma mark - DataLoaderDelegate

- (void)numberOfFiles:(NSUInteger)numberOfFiles inDirectory:(NSString *)directoryPath
{

}

- (void)sensorItemParsed:(SensorItem *)sensorItem
{
    if (self.submitData) {
        if ([_delegate respondsToSelector:@selector(sendSensorItem:)]) {
            [_delegate performSelector:@selector(sendSensorItem:) withObject:sensorItem];
        }
    } else {
        [_cachedItems addObject:sensorItem];
    }
}

- (void)loadingFinished:(BOOL)successfull
{

}

#pragma mark - Public Methods

- (void)startLoading
{
    [_dataLoader startLoading];
}
@end