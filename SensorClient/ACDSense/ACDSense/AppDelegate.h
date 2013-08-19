//
//  AppDelegate.h
//  ACDSense
//
//  Created by Martin Weißbach on 8/19/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MXi/MXi.h>
#import <MXi/MXiBeanDelegate.h>
#import <MXi/MXiStanzaDelegate.h>
#import <MXi/MXiPresenceDelegate.h>

#import "DelegateSensorValues.h"
#import "SensorValue.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MXiBeanDelegate, MXiPresenceDelegate, MXiStanzaDelegate>

@property (strong, nonatomic) MXiConnection *connection;

@property (strong, nonatomic) UIWindow *window;

@end
