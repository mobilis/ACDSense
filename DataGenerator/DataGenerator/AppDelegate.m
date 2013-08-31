//
//  AppDelegate.m
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "AppDelegate.h"

#import "LogFileWriter.h"

#import "NSString+FileReading.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSArray *mucAddresses;
@property (strong, nonatomic) NSMutableArray *connectedMUCAddresses;

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
    self.tempValueCalculator = [[TempValueCalculator alloc] init];
    [self launchConnectionEstablishment];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    // Will be called before applicationDidFinishLaunching:
    // Read in a list of MUCs
    self.mucAddresses = [NSString linesOfStringsOfFile:filename];
    return _mucAddresses ? YES : NO;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self.connection sendBean:[[RemovePublisher alloc] init]];
}

#pragma mark - DataGenerator

- (void)scheduleNewValueCalculation
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        float tempValue = [[self.tempValueCalculator nextValue] floatValue];
        if (self.mucAddresses) {
            for (NSString *roomJID in self.connectedMUCAddresses) {
                [self.connection sendMessage:[NSString stringWithFormat:@"%f+Celsius+%@", tempValue, [self timestamp]]
                                      toRoom:roomJID];
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
        
            SensorValue *sensorValue = [[SensorValue alloc] init];
            sensorValue.subType = @"Generated";
            sensorValue.value = [NSString stringWithFormat:@"%f", tempValue];
            sensorValue.unit = @"Celsius";
        
            [sensorItem.values addObjectsFromArray:[self variateTheValue:sensorValue]];
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
    if (self.mucAddresses) {
        [self.connection setMucDelegate:self];
        self.connectedMUCAddresses = [NSMutableArray arrayWithCapacity:_mucAddresses.count];
        for (NSString *roomJID in self.mucAddresses) {
            [self.connection connectToMultiUserChatRoom:roomJID];
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
    [_connectedMUCAddresses addObject:roomJID];
}

@end
