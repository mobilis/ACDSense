//
//  Subject.h
//  DataGenerator
//
//  Created by Martin Weißbach on 9/14/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Subject : NSObject

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSDictionary *location;
@property(nonatomic, strong) NSArray *weatherKeys;

+ (id)subjectWithComponents:(NSArray *)components;

- (id)initWithComponents:(NSArray *)components;

@end
