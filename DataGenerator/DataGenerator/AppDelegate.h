//
//  AppDelegate.h
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MXi/MXi.h>
#import <MXi/MXiMultiUserChatDelegate.h>

#import "DelegateSensorValues.h"
#import "RegisterPublisher.h"
#import "RemovePublisher.h"
#import "PublishSensorItems.h"

#import "RefreshTimer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, MXiPresenceDelegate, MXiStanzaDelegate, MXiBeanDelegate, MXiMultiUserChatDelegate>

@property (strong, nonatomic) RefreshTimer *refreshTimer;

@property (strong, nonatomic) MXiConnection *connection;

@end
