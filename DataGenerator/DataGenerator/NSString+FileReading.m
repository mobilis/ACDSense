//
//  NSString+FileReading.m
//  DataGenerator
//
//  Created by Martin Weißbach on 8/31/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "NSString+FileReading.h"

@implementation NSString (FileReading)

+ (NSArray *)linesOfStringsOfFile:(NSString *)filePath
{
    NSError *error = nil;
    NSString *completeFileString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return nil;
    }
    
    return [completeFileString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

@end
