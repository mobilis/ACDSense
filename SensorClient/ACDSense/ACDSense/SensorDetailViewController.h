//
//  SensorDetailViewController.h
//  ACDSense
//
//  Created by Martin Weißbach on 9/1/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "SensorItem.h"

#import "CorePlot-CocoaTouch.h"

@interface SensorDetailViewController : UIViewController <CPTPlotDataSource, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) SensorItem *sensorItem;

- (void)addSensorValues:(NSArray *)sensorValues;

@end
