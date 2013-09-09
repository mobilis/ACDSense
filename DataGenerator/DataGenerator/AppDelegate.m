//
//  AppDelegate.m
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "AppDelegate.h"

#import "LogFileWriter.h"
#import "MUCInformation.h"
#import "MUCInfoParser.h"

#import "SensorMUCDomain.h"

#import "NSString+FileReading.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSMutableArray *mucInformation;
@property (strong, nonatomic) NSMutableArray *connectedMUCs;

@property (strong, atomic) ValueCalculator *valueCalculator;

- (void)scheduleNewValueCalculation;
- (NSString *)timestamp;

- (void)launchConnectionEstablishment;
- (void)setUpConnectionToMUCs;
- (NSArray *)incomingBeanPrototypes;

@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self launchConnectionEstablishment];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    // Will be called before applicationDidFinishLaunching:
    // Read in a list of MUCs
    NSArray *rawMUCInformation = [NSString linesOfStringsOfFile:filename];
    self.mucInformation = [NSMutableArray arrayWithCapacity:rawMUCInformation.count];
    for (NSString *rawMUC in rawMUCInformation) {
        [_mucInformation addObject:[[MUCInformation alloc] initWithAddress:[MUCInfoParser parseMUCAddressFromString:rawMUC]
                                                                      type:[MUCInfoParser parseMUCTypeFromString:rawMUC]
                                                                lowerLimit:[MUCInfoParser parseLowerLimitFromString:rawMUC]
                                                                upperLimit:[MUCInfoParser parseUpperLimitFromString:rawMUC]
                                                         intermediarySteps:[MUCInfoParser parseIntermediaryStepsFromString:rawMUC]]];
    }
    return _mucInformation.count > 0 ? YES : NO;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self.connection sendBean:[[RemovePublisher alloc] init]];
}

#pragma mark - DataGenerator

- (void)scheduleNewValueCalculation
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if (self.mucInformation) {
            for (MUCInformation *mucInfo in self.connectedMUCs) {
                [self.connection sendMessage:[NSString stringWithFormat:@"%f+%@+%@", [[mucInfo nextValue] floatValue],
                                              [mucInfo unitOfValues],
                                              [self timestamp]]
                                      toRoom:mucInfo.address];
            }
        } else {
            PublishSensorItems *sensorItems = [[PublishSensorItems alloc] init];
            SensorItem *sensorItem = [[SensorItem alloc] init];
            sensorItem.sensorId = @"DataGenerator_mwb";
        
            Location *sensorLocation = [[Location alloc] init];
            sensorLocation.latitude = 51;
            sensorLocation.longitude = 13;
        
            sensorItem.type = @"Temperature";
            sensorItem.location = sensorLocation;
            
            SensorMUCDomain *sensorDomain = [[SensorMUCDomain alloc] init];
            sensorDomain.domainId = @"46364823482364872364872364783647823648723648";
            sensorDomain.domainURL = @"localhost/DataGenerator";
            
            sensorItem.sensorDomain = sensorDomain;
        
            SensorValue *sensorValue = [[SensorValue alloc] init];
            sensorValue.subType = @"Generated";
            sensorValue.value = [NSString stringWithFormat:@"%f", [[self.valueCalculator nextValue] floatValue]];
            sensorValue.unit = @"Celsius";
            sensorValue.timestamp = [self sensorTimestamp];
        
//            [sensorItem.values addObjectsFromArray:[self variateTheValue:sensorValue]];
            sensorItem.values = [NSMutableArray arrayWithObject:sensorValue];
            if (!sensorItems.sensorItems) {
                sensorItems.sensorItems = [NSMutableArray arrayWithCapacity:1];
            }
            [sensorItems.sensorItems addObject:sensorItem];
        
            [self.connection sendBean:sensorItems];
        }
    });
}
- (NSArray *)variateTheValue:(SensorValue *)value
{
    SensorValue *lowerValue = [value mutableCopy];
    SensorValue *higherValue = [value mutableCopy];
    
    lowerValue.value = [NSString stringWithFormat:@"%f", [lowerValue.value floatValue] - 2.4];
    higherValue.value = [NSString stringWithFormat:@"%f", [lowerValue.value floatValue] + 1.3];
    
    return @[lowerValue, higherValue, value];
}

- (NSString *)timestamp
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    unsigned calendarFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *dateComponents = [currentCalendar components:calendarFlags fromDate:[NSDate date]];
    NSString *year = [NSString stringWithFormat:@"%02ld", (long)[dateComponents year]];
    NSString *month = [NSString stringWithFormat:@"%02ld", (long)[dateComponents month]];
    NSString *day = [NSString stringWithFormat:@"%02ld", (long)[dateComponents day]];
    NSString *hour = [NSString stringWithFormat:@"%02ld", (long)[dateComponents hour]];
    NSString *minute = [NSString stringWithFormat:@"%02ld", (long)[dateComponents minute]];
    NSString *second = [NSString stringWithFormat:@"%02ld", (long)[dateComponents second]];
    
    NSString *dateString = [NSString stringWithFormat:@"%@.%@.%@-%@:%@:%@", day, month, year, hour, minute, second];
    NSLog(@"dateString");
    return dateString;
}

- (Timestamp *)sensorTimestamp
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    unsigned calendarFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *dateComponents = [currentCalendar components:calendarFlags fromDate:[NSDate date]];
    Timestamp *timestamp = [Timestamp new];
    
    timestamp.year = [dateComponents year];
    timestamp.month = [dateComponents month];
    timestamp.day = [dateComponents day];
    timestamp.hour = [dateComponents hour];
    timestamp.minute = [dateComponents minute];
    timestamp.second = [dateComponents second];
    
    return timestamp;
}

#pragma mark - MXi Communication

- (void)launchConnectionEstablishment
{
    NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSDictionary *jabberSettings = [[NSDictionary dictionaryWithContentsOfFile:settingsPath] objectForKey:@"jabberInformation"];
    
    NSString *jid = [jabberSettings valueForKey:@"jid"];
    NSString *password = [jabberSettings valueForKey:@"password"];
    NSString *hostName = [jabberSettings valueForKey:@"hostName"];
    NSString *serviceNamespace = [jabberSettings valueForKey:@"serviceNamespace"];
    NSString *port = [jabberSettings valueForKey:@"port"];
    
    self.connection = [MXiConnection connectionWithJabberID:jid
                                                   password:password
                                                   hostName:hostName
                                                       port:[port integerValue]
                                             coordinatorJID:[NSString stringWithFormat:@"mobilis@%@/Coordinator", hostName]
                                           serviceNamespace:serviceNamespace
                                           presenceDelegate:self
                                             stanzaDelegate:self
                                               beanDelegate:self
                                  listeningForIncomingBeans:[self incomingBeanPrototypes]];
}

- (void)setUpConnectionToMUCs
{
    if (self.mucInformation) {
        [self.connection setMucDelegate:self];
        self.connectedMUCs = [NSMutableArray arrayWithCapacity:_mucInformation.count];
        for (MUCInformation *mucInfo in _mucInformation) {
            [self.connection connectToMultiUserChatRoom:mucInfo.address];
        }
    }
}

- (NSArray *)incomingBeanPrototypes
{
    return nil; // The DG does not listen for incoming beans.
}

#pragma mark - MXiPresenceDelegate

- (void)didAuthenticate
{
    NSLog(@"Authentication successfull");
}

- (void)didDiscoverServiceWithNamespace:(NSString *)serviceNamespace
                                   name:(NSString *)serviceName
                                version:(NSInteger)version
                             atJabberID:(NSString *)serviceJID
{
    NSLog(@"Service Discovered: %@", serviceJID);
    [self.connection sendBean:[[RegisterPublisher alloc] init]];
    self.valueCalculator = [[ValueCalculator alloc] initWithUpperLimit:5.0 lowerLimit:-1.0 intermediarySteps:10];
    self.refreshTimer = [[RefreshTimer alloc] initWithTarget:self invokeMethod:@selector(scheduleNewValueCalculation)];
    [self setUpConnectionToMUCs];
}

- (void)didDisconnectWithError:(NSError *)error
{
    [LogFileWriter writeNSError:error];
}

- (void)didFailToAuthenticate:(NSXMLElement *)error
{
    [LogFileWriter writeXMiError:error];
}

#pragma mark - MXiStanzaDelegate

- (void)didReceiveMessage:(XMPPMessage *)message
{
#warning Potentially unimplemented method
}

- (BOOL)didReceiveIQ:(XMPPIQ *)iq
{
#warning Potentially unimplemented method
    return YES;
}

- (void)didReceivePresence:(XMPPPresence *)presence
{
#warning Potentially unimplemented method
}

- (void)didReceiveError:(NSXMLElement *)error
{
    [LogFileWriter writeXMiError:error];
}

#pragma mark - MXiBeanDelegate

- (void)didReceiveBean:(MXiBean<MXiIncomingBean> *)theBean
{
    if ([theBean class] == [DelegateSensorValues class]) {
        // DataGenerator does not handle incoming Sensor values
        // It's a producer only
    }
}

#pragma mark - MXiMultiUserChatDelegate

- (void)connectionToRoomEstablished:(NSString *)roomJID
{
    for (MUCInformation *mucInfo in _mucInformation) {
        if ([mucInfo.address isEqualToString:roomJID]) {
            [_connectedMUCs addObject:mucInfo];
            break;
        }
    }
}

@end
