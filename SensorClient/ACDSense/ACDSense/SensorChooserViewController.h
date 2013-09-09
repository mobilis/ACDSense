//
//  SensorChooserViewController.h
//  ACDSense
//
//  Created by Martin Weißbach on 9/1/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SensorSelectionDelegate.h"

@interface SensorChooserViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<SensorSelectionDelegate> delegate;

- (void)filterForSensorMUCDomains:(NSArray *)domains;

- (void)addSensorItems:(NSArray *)sensorItems;

@end
