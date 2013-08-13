//
//  AppDelegate.h
//  DataGenerator
//
//  Created by Martin Weißbach on 8/13/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "RefreshTimer.h"
#import "TempValueCalculator.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) RefreshTimer *refreshTimer;
@property (strong, nonatomic) TempValueCalculator *tempValueCalculator;

@end
