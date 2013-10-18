//
// Created by Martin Weißbach on 10/18/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import "ServerComponent.h"
#import "MXiConnectionHandler.h"
#import "RegisterPublisher.h"
#import "RegisterReceiver.h"
#import "CreateSensorMUCDomain.h"
#import "RemovePublisher.h"
#import "RemoveReceiver.h"


@implementation ServerComponent

+ (instancetype)sharedInstance
{

    static dispatch_once_t once;
    static ServerComponent *shared = nil;
    dispatch_once(&once, ^
    {
        shared = [[self alloc] initUniqueInstance];
    });

    return shared;
}

- (id)initUniqueInstance
{
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(registerPublisher:) forBeanClass:[RegisterPublisher class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(registerReceiver:) forBeanClass:[RegisterReceiver class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(removePublisher:) forBeanClass:[RemovePublisher class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(removeReceiver:) forBeanClass:[RemoveReceiver class]];
    [[MXiConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(createMUCDomain:) forBeanClass:[CreateSensorMUCDomain class]];

    return [super init];
}


#pragma mark - Incoming Bean Handler

- (void)removeReceiver:(RemoveReceiver *)removeReceiver
{

}

- (void)removePublisher:(RemovePublisher *)removePublisher
{

}

- (void)registerReceiver:(RegisterReceiver *)registerReceiver
{

}

- (void)registerPublisher:(RegisterPublisher *)registerPublisher
{

}

- (void)createMUCDomain:(CreateSensorMUCDomain *)domain
{

}

@end