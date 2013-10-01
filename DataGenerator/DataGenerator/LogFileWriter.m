//
//  LogFileWriter.m
//  DataGenerator
//
//  Created by Martin Weißbach on 8/16/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "LogFileWriter.h"

@interface LogFileWriter ()

+ (NSURL *)applicationSupportAppUrl;
+ (void)writeToFile:(NSData *)data;

@end

@implementation LogFileWriter

+ (NSURL *)applicationSupportAppUrl
{
    NSError *error = nil;
    NSURL * directoryUrl = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                           inDomain:NSUserDomainMask
                                  appropriateForURL:nil
                                             create:YES
                                              error:&error];
    if (error) {
        return nil;
    }
    directoryUrl = [directoryUrl URLByAppendingPathComponent:@"de.tudresden.inf.rn.acdsense.datagenerator" isDirectory:YES];
    if ([[NSFileManager defaultManager] createDirectoryAtURL:directoryUrl withIntermediateDirectories:YES attributes:nil error:&error]) {
        return directoryUrl;
    }
    return nil;
}

+ (void)writeToFile:(NSData *)data
{
    NSString *dateString = [[NSDate date] descriptionWithLocale:[NSLocale systemLocale]];
    NSString *filePath = [NSString stringWithFormat:@"%@.txt", dateString];
    
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
}

+ (void)writeXMiError:(NSXMLElement *)error
{
    [self writeToFile:[[error description] dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)writeNSError:(NSError *)error
{
    NSString *string = [NSString stringWithFormat:@"Code: %ld\nDomain: %@\nUser-Info:%@", error.code, error.domain, error.userInfo];
    [self writeToFile:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
