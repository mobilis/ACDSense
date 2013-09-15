//
// Created by Martin Weißbach on 9/15/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class SensorItem;

@protocol XMLReaderDelegate

- (void)parsingFinished:(BOOL)successfull;
- (void)parsedSensorItem:(SensorItem *)sensorItem;

@end

@interface XMLReader : NSObject <NSXMLParserDelegate>

@property (weak, nonatomic) id<XMLReaderDelegate> delegate;

- (id)initWithString:(NSString *)xmlContent;

- (void)parse;
- (void)abortParsing;

@end