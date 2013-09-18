//
// Created by Martin Weißbach on 9/16/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LoaderOperation.h"
#import "SensorItem.h"
#import "XMLReader.h"

@interface LoaderOperation () <XMLReaderDelegate> {
    BOOL _executing, _finished;
}

@property (atomic, strong) XMLReader *xmlReader;
@property (atomic, strong) SensorItem *parsedSensorItem;

@end

@implementation LoaderOperation

#pragma mark - Custom Initialization

- (id)initWithXMLString:(NSString *)xmlString
{
    self = [super init];
    if (self) {
        self.xmlReader = [[XMLReader alloc] initWithString:xmlString];
        self.xmlReader.delegate = self;
    }

    return self;
}

#pragma mark - NSOperation Subclassing

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    @synchronized (self) {
        return _executing;
    }
}

- (BOOL)isFinished
{
    @synchronized (self) {
        return _finished;
    }
}

- (void)start
{
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        [self.xmlReader parse];
    });
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main
{
    while (!self.isCancelled && self.isExecuting)
        ;
    [self.xmlReader abortParsing];
}

#pragma mark - Public Accessors

- (SensorItem *)sensorItem
{
    return self.parsedSensorItem;
}

#pragma mark - Private Helper

- (void)completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    _executing = NO;
    _finished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - XMLReaderDelegate

- (void)parsingFinished:(BOOL)successfull
{
    [self completeOperation];

}

- (void)parsedSensorItem:(SensorItem *)sensorItem
{
    self.parsedSensorItem = sensorItem;
}


@end