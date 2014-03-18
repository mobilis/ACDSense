//
//  CoreDataStack.h
//  ACDSense
//
//  Created by Martin Weissbach on 3/18/14.
//  Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataStack : NSObject

+ (instancetype)coreDataStack;

- (NSManagedObjectContext *)managedObjectContext;

- (NSMutableDictionary *)sensorMUCs;

@end
