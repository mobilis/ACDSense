//
//  LogFileWriter.h
//  DataGenerator
//
//  Created by Martin Weißbach on 8/16/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogFileWriter : NSObject

+ (void)writeNSError:(NSError *)error;
+ (void)writeXMiError:(NSXMLElement *)error;

@end
