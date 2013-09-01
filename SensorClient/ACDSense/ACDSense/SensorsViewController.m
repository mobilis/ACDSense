//
//  SensorsViewController.m
//  ACDSense
//
//  Created by Markus Wutzler on 28.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SensorsViewController.h"

#import "SensorChooserViewController.h"

#import "ConnectionHandler.h"

#import "DelegateSensorItems.h"

@interface SensorsViewController ()

@property (weak) SensorChooserViewController *sensorsViewController;
@property (weak) UIViewController *sensorDetailViewController;

- (void)registerBeanListener;

- (void)sensorItemsReceived:(DelegateSensorItems *)sensorItems;

@end

@implementation SensorsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.view removeConstraints:self.view.constraints];
	UIView *upperView = self.sensorsView;
	UIView *lowerView = self.sensorDetailView;
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[upperView][lowerView(==upperView)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(upperView,lowerView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[upperView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(upperView,lowerView)]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[lowerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(upperView,lowerView)]];
    
    [self registerBeanListener];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"sensorsViewSegue"]) {
        NSLog(@"Seque for SensorsView called");
        self.sensorsViewController = [segue destinationViewController];
    }
}

#pragma mark - MXiCommunication

- (void)registerBeanListener
{
    [[ConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(sensorItemsReceived:) forBeanClass:[DelegateSensorItems class]];
}

- (void)sensorItemsReceived:(DelegateSensorItems *)sensorItems
{
    if (![sensorItems isKindOfClass:[DelegateSensorItems class]]) { // just defensive programming to simplify debugging
        NSLog(@"Severe issue in the DelegateBeanMapping");
        return;
    }
    
    [_sensorsViewController addSensorItems:sensorItems.sensorItems];
}

@end
