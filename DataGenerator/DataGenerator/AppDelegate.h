//
//  AppDelegate.h
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MXi/MXi.h>
#import "DelegateSensorValues.h"
#import "RegisterPublisher.h"
#import "RemovePublisher.h"
#import "PublishSensorItems.h"

#import "RefreshTimer.h"
#import "TempValueCalculator.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, MXiPresenceDelegate, MXiStanzaDelegate, MXiBeanDelegate>

@property (strong, nonatomic) RefreshTimer *refreshTimer;
@property (strong, nonatomic) TempValueCalculator *tempValueCalculator;

@property (strong, nonatomic) MXiConnection *connection;

@end
