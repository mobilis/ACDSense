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

#import "NSString+FileReading.h"
#import "MainWindowController.h"
#import "DataHandler.h"
#import "MessageProcessor.h"
#import "SensorItem+Equality.h"

@interface AppDelegate () <DataHandlerDelegate>

@property (strong, nonatomic) MainWindowController *mainWindowController;

@property (strong, nonatomic) NSMutableArray *mucInformation;
@property (strong, nonatomic) NSMutableArray *connectedMUCs;

@property (strong, atomic) DataHandler *dataHandler;

- (NSString *)timestamp;

- (void)setUpConnectionToMUCs;
- (NSArray *)incomingBeanPrototypes;

@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    self.mainWindowController.delegate = self;
    [self.mainWindowController.window makeKeyAndOrderFront:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self.connection sendBean:[[RemovePublisher alloc] init]];
}

#pragma mark - DataGenerator

- (void)getMUCInformationFromFile:(NSString *)pathToFile
{
    NSArray *rawMUCInformation = [NSString linesOfStringsOfFile:pathToFile];
    self.mucInformation = [NSMutableArray arrayWithCapacity:rawMUCInformation.count];
    for (NSString *rawMUC in rawMUCInformation) {
        [_mucInformation addObject:[[MUCInformation alloc] initWithAddress:[MUCInfoParser parseMUCAddressFromString:rawMUC]
                                                               andSensorID:[MUCInfoParser parseSensorIDFromString:rawMUC]]];
    }
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

- (void)launchDataLoadingFromDirectory:(NSString *)directory
{
    @autoreleasepool {
        self.dataHandler = [DataHandler dataHandlerWithDelegate:self andDirectory:directory];
    }
    [self.dataHandler startLoading];
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
    // DataGenerator does not handle incoming Sensor values
    // It's a producer only
    return;
}

#pragma mark - MXiMultiUserChatDelegate

- (void)connectionToRoomEstablished:(NSString *)roomJID
{
    for (MUCInformation *mucInfo in _mucInformation) {
        if ([mucInfo.address isEqualToString:roomJID]) {
            [_connectedMUCs addObject:mucInfo];
            [self.dataHandler setSubmitData:YES];
            break;
        }
    }
}

#pragma mark - DataHandlerDelegate

- (void)sendSensorItem:(SensorItem *)sensorItem
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        for (MUCInformation *mucInfo in self.connectedMUCs)
            if ([sensorItem isSameSensorID:mucInfo.sensorID]) {
                for (SensorValue *value in sensorItem.values)
                    [self.connection sendMessage:[MessageProcessor messageWithSensorValue:value]
                                          toRoom:mucInfo.address];
                break;
            }
    });
}

@end
