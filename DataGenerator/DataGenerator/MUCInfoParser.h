//
//  MUCInfoParser.h
//  DataGenerator
//
//  Created by Martin Weißbach on 9/3/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUCInfoParser : NSObject

+ (NSString *)parseMUCAddressFromString:(NSString *)string;
+ (NSString *)parseSensorIDFromString:(NSString *)string;

@end
