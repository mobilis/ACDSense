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

/**
*   Create a new XMLReader instance with a given string that contains xml data.
*
*   @param xmlContent A string that contains xml conforming data.
*
*   @return A new XMLReader instance.
*/
- (id)initWithString:(NSString *)xmlContent;

/**
*   Start parsing the xml data this instance was initialized with.
*/
- (void)parse;

/**
*   Abort the parsing of the xml data. Calling this method is only required if the parsing should be interrupted.
*/
- (void)abortParsing;

@end