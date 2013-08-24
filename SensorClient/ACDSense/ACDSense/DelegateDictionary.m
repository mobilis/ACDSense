//
//  DelegateDictionary.m
//  ACDSense
//
//  Created by Martin Weißbach on 8/24/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "DelegateDictionary.h"

@interface DelegateDictionary ()

@property (strong, nonatomic) NSMutableDictionary *delegateDictionary;

- (void)initializeDictionaryIfNotExisting;
- (NSString *)classNameForClass:(Class)class;

@end

@implementation DelegateDictionary

#pragma mark - Singleton stack

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    __strong static DelegateDictionary *shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[super alloc] initUniqueInstance];
    });
    return shared;
}

- (instancetype)initUniqueInstance
{
    return [super init];
}

#pragma mark - Delegate Handling

- (void)addDelegate:(id)delegate forBeanClass:(Class)beanClass
{
    [self initializeDictionaryIfNotExisting];
    
    NSArray *registeredDelegates = [self.delegateDictionary objectForKey:[self classNameForClass:beanClass]];
    if (!registeredDelegates) {
        [self.delegateDictionary setObject:@[delegate] forKey:[self classNameForClass:beanClass]];
    } else {
        NSMutableArray *newRegisteredDelegates = [[NSMutableArray alloc] initWithCapacity:registeredDelegates.count+1];
        [newRegisteredDelegates addObjectsFromArray:registeredDelegates];
        [newRegisteredDelegates addObject:delegate];
        [self.delegateDictionary setObject:newRegisteredDelegates forKey:[self classNameForClass:beanClass]];
    }
}

- (void)removeDelegate:(id)delegate forBeanClass:(Class)beanClass
{
    [self initializeDictionaryIfNotExisting];
    NSMutableArray *registeredDelegates = [self.delegateDictionary objectForKey:[self classNameForClass:beanClass]];
    if (registeredDelegates) {
        [registeredDelegates removeObject:delegate];
        [self.delegateDictionary setObject:registeredDelegates forKey:[self classNameForClass:beanClass]];
    }
}

- (NSArray *)delegatesForBeanClass:(Class)beanClass
{
    [self initializeDictionaryIfNotExisting];
    return [self.delegateDictionary objectForKey:[self classNameForClass:beanClass]];
}

#pragma mark - Private Methods

- (void)initializeDictionaryIfNotExisting
{
    if (!self.delegateDictionary) {
        self.delegateDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
}

- (NSString *)classNameForClass:(Class)class
{
    NSKeyedArchiver *archiver = [NSKeyedArchiver new];
    return [archiver classNameForClass:class];
}

@end
