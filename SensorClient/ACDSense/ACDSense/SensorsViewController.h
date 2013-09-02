//
//  SensorsViewController.h
//  ACDSense
//
//  Created by Markus Wutzler on 28.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SensorSelectionDelegate.h"

@interface SensorsViewController : UIViewController <SensorSelectionDelegate>
@property (weak, nonatomic) IBOutlet UIView *sensorsView;
@property (weak, nonatomic) IBOutlet UIView *sensorDetailView;

@end
