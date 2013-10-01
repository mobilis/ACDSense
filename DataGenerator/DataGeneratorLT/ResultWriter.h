//
//  ResultWriter.h
//  DataGenerator
//
//  Created by Martin Weißbach on 9/26/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResultWriter : NSObject

+ (void)writeArrayToCVS:(NSArray *)resultData inDirectory:(NSString *)directoryPath withFileName:(NSString *)fileName;

@end
