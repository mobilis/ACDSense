//
//  ResultWriter.m
//  DataGenerator
//
//  Created by Martin Weißbach on 9/26/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "ResultWriter.h"

#import "RoundtripInfo.h"
#import "NSString+FileReading.h"

@implementation ResultWriter

+ (void)writeArrayToCVS:(NSArray *)resultData inDirectory:(NSString *)directoryPath withFileName:(NSString *)fileName
{
    if (!resultData || resultData.count == 0 || [fileName rangeOfString:@".cvs"].location == NSNotFound)
        return;
    
    NSMutableString *cvsAsString = [NSMutableString new];
    for (RoundtripInfo *roundtripInfo in resultData) {
        [cvsAsString appendFormat:@"%@,%@,%@,%lu\n", roundtripInfo.sent, roundtripInfo.received, roundtripInfo.roundtrip, (unsigned long)roundtripInfo.block];
    }
    
    [[NSFileManager defaultManager] createFileAtPath:[self buildcompleteFilePathFromDirectory:directoryPath andFileName:fileName]
                                            contents:[cvsAsString dataUsingEncoding:NSUTF8StringEncoding]
                                          attributes:nil];
}

+ (NSString *)buildcompleteFilePathFromDirectory:(NSString *)directoryPath andFileName:(NSString *)fileName
{
    NSURL *directoryURL = [NSURL URLWithString:directoryPath];
    NSURL *completeURL = [directoryURL URLByAppendingPathComponent:fileName];

    return [NSString fileLessFilePath:[completeURL absoluteString]];
}

@end
