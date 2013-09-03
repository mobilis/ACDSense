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

+ (NSArray *)linesOfStringsOfFile:(NSString *)filePath
{
    NSError *error = nil;
    NSString *completeFileString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
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
