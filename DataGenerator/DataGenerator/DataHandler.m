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

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) NSUInteger counter;

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
        self.counter = 0;
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
        self.timer = [NSTimer timerWithTimeInterval:15.0 target:self selector:@selector(fireItem) userInfo:nil repeats:YES];
    else {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void)fireItem
{
    if ([_delegate respondsToSelector:@selector(sendSensorItem:)])
        [_delegate performSelector:@selector(sendSensorItem:) withObject:[self.cachedItems objectAtIndex:(self.counter++)]];
}

#pragma mark - DataLoaderDelegate

- (void)numberOfFiles:(NSUInteger)numberOfFiles inDirectory:(NSString *)directoryPath
{

}

- (void)sensorItemParsed:(SensorItem *)sensorItem
{
    [_cachedItems addObject:sensorItem];
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