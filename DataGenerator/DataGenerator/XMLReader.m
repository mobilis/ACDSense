//
// Created by Martin Weißbach on 9/15/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "XMLReader.h"
#import "SensorItem.h"


@interface XMLReader ()

@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSMutableString *tagContent;

@property (nonatomic, strong) SensorItem *sensorItem;
@property (nonatomic, strong) SensorValue *sensorValue;
@property (nonatomic, strong) Timestamp *timestamp;

@end

@implementation XMLReader

- (id)initWithString:(NSString *)xmlContent
{
    self = [super init];
    if (self) {
        self.parser = [[NSXMLParser alloc] initWithData:[xmlContent dataUsingEncoding:NSUTF8StringEncoding]];
        [self.parser setDelegate:self];

        self.tagContent = [NSMutableString string];
    }

    return self;
}

- (void)parse
{
    BOOL finish = [_parser parse];
    [_delegate parsingFinished:finish];
}

- (void)abortParsing
{
    [_parser abortParsing];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName compare:@"sensorItem" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        self.sensorItem = [[SensorItem alloc] init];
        self.sensorItem.values = [NSMutableArray new];
    }
    if ([elementName compare:@"timestamp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        self.timestamp = [[Timestamp alloc] init];
    }
    if ([elementName compare:@"value" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        self.sensorValue = [[SensorValue alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName compare:@"sensorId" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _sensorItem.sensorId = [NSString stringWithString:_tagContent];
    }
    if ([elementName compare:@"type" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _sensorItem.type = [NSString stringWithString:_tagContent];
    }
    if ([elementName compare:@"value" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _sensorValue.value = [NSString stringWithString:_tagContent];
    }
    if ([elementName compare:@"unit" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _sensorValue.unit = [NSString stringWithString:_tagContent];
    }
    if ([elementName compare:@"subType" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _sensorValue.subType = [NSString stringWithString:_tagContent];
    }
    if ([elementName compare:@"hour" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _timestamp.hour = [_tagContent integerValue];
    }
    if ([elementName compare:@"minute" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _timestamp.minute = [_tagContent integerValue];
    }
    if ([elementName compare:@"second" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _timestamp.second = [_tagContent integerValue];
    }
    if ([elementName compare:@"year" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _timestamp.year = [_tagContent integerValue];
    }
    if ([elementName compare:@"month" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _timestamp.month = [_tagContent integerValue];
    }
    if ([elementName compare:@"day" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _timestamp.day = [_tagContent integerValue];
    }
    if ([elementName compare:@"values" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        [_sensorItem.values addObject:_sensorValue];
    }
    if ([elementName compare:@"timestamp" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        _sensorValue.timestamp = _timestamp;
    }
    self.tagContent = [NSMutableString new];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_tagContent appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [_delegate parsedSensorItem:_sensorItem];
}

@end