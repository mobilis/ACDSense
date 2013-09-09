//
//  SensorSelectionDelegate.h
//  ACDSense
//
//  Created by Martin Weißbach on 9/2/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SensorItem;

@protocol SensorSelectionDelegate <NSObject>

/**
 *  Tell the receiver which sensor item is currently selected and for which the user wants to see additional information.
 *
 *  @param sensorItem The sensor item for which additional information should be depicted.
 */
- (void)updateSensorItemWithSensorItem:(SensorItem *)sensorItem;

@end
