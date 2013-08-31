//
//  NSString+FileReading.h
//  DataGenerator
//
//  Created by Martin Weißbach on 8/31/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileReading)

+ (NSArray *)linesOfStringsOfFile:(NSString *)filePath;

@end
