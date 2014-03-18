//
//  CoreDataStack.m
//  ACDSense
//
//  Created by Martin Weissbach on 3/18/14.
//  Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CoreDataStack.h"
#import "SensorMUC.h"

@implementation CoreDataStack
{
    NSManagedObjectContext *__managedObjectContext;
}

#pragma mark - Singleton Stack

+ (instancetype)coreDataStack
{
    static CoreDataStack *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [((CoreDataStack *)[super allocWithZone:NULL]) initUnique];
    });
    
    return __sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self coreDataStack];
}

- (id)initUnique
{
    [self setup];
    
    return self;
}

#pragma mark - Public Interface

- (NSManagedObjectContext *)managedObjectContext
{
    return __managedObjectContext;
}

- (NSMutableDictionary *)sensorMUCs
{
    NSError *error = nil;
    NSArray *allMUCs = [__managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"SensorMUC"]
                                                             error:&error];
    if (error) return nil;

    NSMutableDictionary *orderedMUCs = [NSMutableDictionary new];
    for (SensorMUC *sensorMUC in allMUCs)
    {
        if ([orderedMUCs objectForKey:sensorMUC.domainName] == nil)
        {
            [orderedMUCs setObject:[@[sensorMUC] mutableCopy] forKey:sensorMUC.domainName];
        }
        else
        {
            [[orderedMUCs objectForKey:sensorMUC.domainName] addObject:sensorMUC];
        }
    }

    return orderedMUCs;
}

#pragma mark - CoreData Stack

- (void)setup
{
    __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];

    NSError *error;
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:[self storeURL]
                                    options:nil
                                      error:&error];
    #if TARGET_IPHONE_SIMULATOR
    if (error) NSLog(@"[CoreDataStack setup] error: %@", error);
    #endif

    __managedObjectContext.persistentStoreCoordinator = coordinator;
}

- (NSURL *)storeURL
{
    NSURL *directory = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                              inDomain:NSUserDomainMask
                                                     appropriateForURL:nil
                                                                create:YES
                                                                 error:NULL];
    NSURL *appDirectory = [directory URLByAppendingPathComponent:@"ACDSense" isDirectory:YES];
    if (![[NSFileManager defaultManager] createDirectoryAtURL:appDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL]) return nil;

    return [appDirectory URLByAppendingPathComponent:@"db.sqlite"];
}

- (NSManagedObjectModel *)managedObjectModel
{
#pragma clang diagnostic push
#pragma ide diagnostic ignored "ResourceNotFoundInspection"
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
#pragma clang diagnostic pop
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return model;
}

@end
