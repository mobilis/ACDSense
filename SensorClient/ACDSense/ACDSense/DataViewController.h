//
//  DataViewController.h
//  ACDSense
//
//  Created by Martin Weißbach on 8/19/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SensorValue.h"

@interface DataViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

- (void)addSensorValue:(SensorValue *)sensorValue;
- (void)addSensorValues:(NSArray *)sensorValues;

@end
