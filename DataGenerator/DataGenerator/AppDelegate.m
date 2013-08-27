//
//  AppDelegate.m
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "AppDelegate.h"

#import "LogFileWriter.h"

@interface AppDelegate ()

- (void)scheduleNewValueCalculation;

- (void)launchConnectionEstablishment;
- (NSArray *)incomingBeanPrototypes;

@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.tempValueCalculator = [[TempValueCalculator alloc] init];
    [self launchConnectionEstablishment];
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
        [sensorItems.sensorItems addObject:sensorItem];
        
        [self.connection sendBean:sensorItems];
    });
}
- (NSArray *)variateTheValue:(SensorValue *)value
{
    SensorValue *lowerValue = [value copy];
    SensorValue *higherValue = [value copy];
    
    lowerValue.value = [NSString stringWithFormat:@"%@", [lowerValue.value floatValue] - 2.4];
    higherValue.value = [NSString stringWithFormat:@"%@", [lowerValue.value floatValue] + 1.3];
    
    return @[lowerValue, higherValue, value];
}

#pragma mark - MXi Communication

- (void)launchConnectionEstablishment
{
    NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSDictionary *jabberSettings = [[NSDictionary dictionaryWithContentsOfFile:settingsPath] objectForKey:@"jabberInformation"];
    
    NSString *jid = [jabberSettings valueForKey:@"jid"];
    NSString *password = [jabberSettings valueForKey:@"password"];
    NSString *hostName = [jabberSettings valueForKey:@"hostName"];
    NSString *serviceJid = [jabberSettings valueForKey:@"serviceJid"];
    
    self.connection = [MXiConnection connectionWithJabberID:jid
                                                   password:password
                                                   hostName:hostName
                                                 serviceJID:serviceJid
                                           presenceDelegate:self
                                             stanzaDelegate:self
                                               beanDelegate:self
                                  listeningForIncomingBeans:[self incomingBeanPrototypes]];
}

- (NSArray *)incomingBeanPrototypes
{
    return @[[[DelegateSensorValues alloc] init]];
}

#pragma mark - MXiPresenceDelegate

- (void)didAuthenticate
{
    [self.connection sendBean:[[RegisterPublisher alloc] init]];
    self.refreshTimer = [[RefreshTimer alloc] initWithTarget:self invokeMethod:@selector(scheduleNewValueCalculation)];
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
@end
