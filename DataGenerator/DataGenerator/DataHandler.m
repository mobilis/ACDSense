//
// Created by Martin Weißbach on 9/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DataHandler.h"
#import "SensorItem.h"
#import "SensorValue.h"

@interface DataHandler ()

@property (strong) NSMutableArray *cachedItems;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) NSUInteger counter;
@property (nonatomic) int finishCounter;

@end

@implementation DataHandler

static void *KVOContext;

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
        self.finishCounter = 0;

        [self addObserver:self forKeyPath:@"finishCounter" options:NSKeyValueObservingOptionNew context:KVOContext];
    }
    
    return self;
}

#pragma mark - KVO Compliance

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KVOContext) {
        if (self.finishCounter == self.cachedItems.count)
            self.submitData = NO;
    }
}

#pragma mark - Custom Getter & Setter

- (void)setSubmitData:(BOOL)submitData
{
    if (_submitData == submitData)
        return;

    _submitData = submitData;
    if (_submitData) {
        self.timer = [NSTimer timerWithTimeInterval:15.0 target:self selector:@selector(fireItem) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    else {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void)fireItem
{
    if ([_delegate respondsToSelector:@selector(sendSensorValue:forSensorID:)]) {
        for (SensorItem *item in _cachedItems) {
            if (self.counter + 1 < item.values.count)
                [_delegate performSelector:@selector(sendSensorValue:forSensorID:) 
                                withObject:[item.values objectAtIndex:(self.counter++)] 
                                withObject:item.sensorId];
            else self.finishCounter++;
        }
    }
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
    NSLog(@"DataHandler loading finished successfully :%d", successfull);
}

#pragma mark - Public Methods

- (void)startLoading
{
    [_dataLoader startLoading];
}
@end