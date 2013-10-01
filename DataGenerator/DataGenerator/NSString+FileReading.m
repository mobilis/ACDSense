//
//  NSString+FileReading.m
//  DataGenerator
//
//  Created by Martin Weißbach on 8/31/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "NSString+FileReading.h"

#import "LogFileWriter.h"

@implementation NSString (FileReading)

+ (NSString *)contentsOfFile:(NSString *)filePath
{
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:filePath]
                                                      encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return nil;
    }
    
    return fileContent;
}
+ (NSString *)fileLessFilePath:(NSString *)filePath
{
    return [filePath stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
}

+ (NSString *)contentsOfFile:(NSString *)fileName inDirectory:(NSString *)directory
{
    NSError *error = nil;
    NSString *fileContent = nil;
    @autoreleasepool {
        NSURL *directoryURL = [NSURL URLWithString:directory];
        NSURL *filePathURL = [directoryURL URLByAppendingPathComponent:fileName];
        fileContent = [[NSString alloc] initWithContentsOfURL:filePathURL encoding:NSUTF8StringEncoding error:&error];
    }
    if (error)
        return nil;

    return fileContent;
}

+ (NSArray *)pointSeparatedComponentsOfString:(NSString *)string
{
    return [string componentsSeparatedByString:@"."];
}

+ (NSArray *)linesOfStringsOfFile:(NSString *)filePath
{
    NSString *completeFileString = [self contentsOfFile:filePath];
    if (!completeFileString) {
        return nil;
    }
    
    NSArray *allLines = [completeFileString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *contentLines = [[NSMutableArray alloc] initWithCapacity:allLines.count];
    for (NSString *line in allLines) {
        @try {
            if (![[line substringToIndex:2] isEqualToString:@"//"]) {
                [contentLines addObject:line];
            }
        }
        @catch (NSException *exception) {
            [LogFileWriter writeNSError:[NSError errorWithDomain:@"ReadRoomList" code:0 userInfo:nil]];
        }
    }
    return contentLines;
}

@end
