//
//  DelegateDictionary.m
//  ACDSense
//
//  Created by Martin Weißbach on 8/24/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "DelegateDictionary.h"

#import "DelegateSelectorMapping.h"

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

- (void)addDelegate:(id)delegate withSelector:(SEL)selector forBeanClass:(Class)beanClass
{
    [self initializeDictionaryIfNotExisting];
    
    DelegateSelectorMapping *delegateSelectorMapping = [[DelegateSelectorMapping alloc] initWithDelegate:delegate
                                                                                             andSelector:selector];
    
    NSArray *registeredDelegates = [self.delegateDictionary objectForKey:[self classNameForClass:beanClass]];
    if (!registeredDelegates) {
        [self.delegateDictionary setObject:@[delegateSelectorMapping] forKey:[self classNameForClass:beanClass]];
    } else {
        BOOL duplicate = NO;
        for (DelegateSelectorMapping *mapping in registeredDelegates) {
            if ([mapping isEqualToDelegate:delegate withSelector:selector]) {
                duplicate = YES;
                break;
            }
        }
        if (duplicate) return;
        
        NSMutableArray *newRegisteredDelegates = [[NSMutableArray alloc] initWithCapacity:registeredDelegates.count+1];
        [newRegisteredDelegates addObjectsFromArray:registeredDelegates];
        [newRegisteredDelegates addObject:delegateSelectorMapping];
        [self.delegateDictionary setObject:newRegisteredDelegates forKey:[self classNameForClass:beanClass]];
    }
}

- (void)removeDelegate:(id)delegate forBeanClass:(Class)beanClass
{
    [self initializeDictionaryIfNotExisting];
    NSMutableArray *registeredDelegates = [self.delegateDictionary objectForKey:[self classNameForClass:beanClass]];
    if (registeredDelegates) {
        NSMutableArray *mappingsToDelete = [NSMutableArray arrayWithCapacity:registeredDelegates.count];
        for (DelegateSelectorMapping *mapping in registeredDelegates) {
            if ([mapping.delegate isEqual:delegate]) {
                [mappingsToDelete addObject:mapping];
            }
        }
        [registeredDelegates removeObjectsInArray:mappingsToDelete];
        [self.delegateDictionary setObject:registeredDelegates forKey:[self classNameForClass:beanClass]];
    }
}

- (void)removeDelegate:(id)delegate withSelector:(SEL)selector forBeanClass:(Class)beanClass
{
    if (selector == nil) {
        [self removeDelegate:delegate forBeanClass:beanClass];
    } else {
        [self initializeDictionaryIfNotExisting];
        NSMutableArray *registeredDelegates = [self.delegateDictionary objectForKey:[self classNameForClass:beanClass]];
        if (registeredDelegates) {
            DelegateSelectorMapping *mappingToRemove = nil;
            for (DelegateSelectorMapping *mapping in registeredDelegates) {
                if ([mapping isEqualToDelegate:delegate withSelector:selector]) {
                    mappingToRemove = mapping;
                    break;
                }
            }
            [registeredDelegates removeObject:mappingToRemove];
            [self.delegateDictionary setObject:registeredDelegates forKey:[self classNameForClass:beanClass]];
        }
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
    return [NSKeyedArchiver classNameForClass:class];
}

@end
