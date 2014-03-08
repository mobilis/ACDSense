//
//  SensorsViewController.h
//  ACDSense
//
//  Created by Markus Wutzler on 28.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CorePlot-CocoaTouch.h"

@class SensorMUCDomain;
@class SensorMUC;

@interface SensorsViewController : UIViewController <UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate, CPTPlotDataSource, MKMapViewDelegate>

- (void)filterForDomain:(SensorMUCDomain *)domain;
- (void)filterForDomains:(NSArray *)domains;

- (void)connectToSensorMUC:(SensorMUC *)sensorMUC;

@end
