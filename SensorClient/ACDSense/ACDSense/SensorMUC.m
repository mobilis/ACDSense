//
// Created by Martin Weissbach on 2/25/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import "SensorMUC.h"
#import "XMPPJID.h"
#import "Location.h"
#import "SensorMUCDomain.h"
#import "SensorMUCDomain+Location.h"

#import <SBJson/SBJson4Parser.h>


@interface SensorMUC ()

@property (nonatomic, readwrite) XMPPJID *jabberID;
@property (nonatomic, readwrite) NSString *domainName;

@end

@implementation SensorMUC
{
    NSString *_type;
    Location *_location;

    NSString *_domainID;
}

- (id)initWithJabberID:(XMPPJID *)jabberID domainName:(NSString *)domainName andDescription:(NSString *)description;
{
    if (self = [super init])
    {
        self.jabberID = jabberID;
        self.domainName = domainName;
        
        [self parseDescription:description];
    }

    return self;
}

- (NSString *)type
{
    return _type;
}

- (Location *)location
{
    return _location;
}

- (SensorMUCDomain *)copyAsSensorMUCDomain
{
    SensorMUCDomain *sensorMUCDomain = [SensorMUCDomain new];
    sensorMUCDomain.domainURL = self.domainName;
    if (_domainID == nil) _domainID = [[NSUUID UUID] UUIDString];
    sensorMUCDomain.domainId = _domainID;
    sensorMUCDomain.location = _location;

    return sensorMUCDomain;
}

- (void)parseDescription:(NSString *)description
{
    // {"sensormuc":{"type":"MULTI","format":"full","location":{"countryCode":"DE","cityName":"Dresden","latitude":51.025714,"longitude":13.722278}}}
    
    SBJson4Parser *parser = [SBJson4Parser parserWithBlock:^(id item, BOOL *stop) {
        if ([item isKindOfClass:[NSMutableDictionary class]])
        {
            NSMutableDictionary *information = [((NSMutableDictionary *)item) objectForKey:@"sensormuc"];
            _type = [information valueForKey:@"type"];
            _location = [self parseLocation:(NSMutableDictionary *)[information objectForKey:@"location"]];
        }
    }
                                            allowMultiRoot:NO
                                           unwrapRootArray:NO
                                              errorHandler:^(NSError *error) {
                                                  @throw [NSException exceptionWithName:@"JSON Parser error" reason:[NSString stringWithFormat:@"%i",error.code] userInfo:error.userInfo];
                                              }];
    
    NSData *jsonData = [description dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        @throw [NSException exceptionWithName:@"Json to Data error" reason:@"Json could not be converted to NSData" userInfo:nil];
    }
    
    if (SBJson4ParserComplete == [parser parse:jsonData]) return;
}

- (Location *)parseLocation:(NSMutableDictionary *)rawLocation
{
    Location *location = [Location new];
    location.latitude = [[rawLocation valueForKey:@"latitude"] floatValue];
    location.longitude = [[rawLocation valueForKey:@"longitude"] floatValue];
    location.locationName = [rawLocation valueForKey:@"cityName"];
    
    return location;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;

    if ([object hash] == [self hash]) return YES;
    else return NO;
}

- (NSUInteger)hash
{
    return [self.domainName hash] | [self.jabberID hash];
}

@end