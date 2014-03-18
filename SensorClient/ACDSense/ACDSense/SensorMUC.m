//
// Created by Martin Weissbach on 2/25/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import "SensorMUC.h"
#import "XMPPJID.h"
#import "Location.h"
#import "SensorMUCDomain.h"
#import "SensorMUCDomain+Location.h"
#import "CoreDataStack.h"

#import <SBJson/SBJson4Parser.h>

#import <objc/runtime.h>

@interface SensorMUC ()

@property (nonatomic, readwrite) NSString *jabberID;
@property (nonatomic, readwrite) NSString *domainName;
@property (nonatomic, readwrite) NSString *jsonDescription;

@end

@implementation SensorMUC
{
    NSString *_type;
    Location *_location;

    NSString *_domainID;
}

@dynamic jabberID, domainName, jsonDescription;

+ (instancetype)sensorMUCwithJabberID:(XMPPJID *)jabberID domainName:(NSString *)domainName andDescription:(NSString *)description
{
    NSString *entityName = [NSString stringWithUTF8String:object_getClassName(self)];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jabberID like %@ AND domainName like %@" argumentArray:@[jabberID.full, domainName]];

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = predicate;

    NSError *error;
    NSArray *results = [[CoreDataStack coreDataStack].managedObjectContext executeFetchRequest:request error:&error];

    if (error != nil)
        return nil;
    else if (results.count == 0)
        return [[self alloc] initWithJabberID:jabberID domainName:domainName andDescription:description];
    else return [results firstObject];
}

- (id)initWithJabberID:(XMPPJID *)jabberID domainName:(NSString *)domainName andDescription:(NSString *)description;
{
    NSManagedObjectContext *context = [CoreDataStack coreDataStack].managedObjectContext;
    NSString *entityName = [NSString stringWithUTF8String:object_getClassName(self)];
    
    if (self = [super initWithEntity:[NSEntityDescription entityForName:entityName
                                                 inManagedObjectContext:context]
      insertIntoManagedObjectContext:context])
    {
        self.jabberID = jabberID.full;
        self.domainName = domainName;
        self.jsonDescription = description;
        
        [self parseDescription:description];
    }

    return self;
}

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    [self parseDescription:self.jsonDescription];
}

#pragma mark - Public Interface

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

#pragma mark - JSON Parser

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
                                                  @throw [NSException exceptionWithName:@"JSON Parser error" reason:[NSString stringWithFormat:@"%li",(long)error.code] userInfo:error.userInfo];
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

@end