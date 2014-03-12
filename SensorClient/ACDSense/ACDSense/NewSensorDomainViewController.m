//
//  NewSensorDomainViewController.m
//  ACDSense
//
//  Created by Martin Weissbach on 2/24/14.
//  Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import "NewSensorDomainViewController.h"
#import "SensorDomainsViewController.h"

@interface NewSensorDomainViewController ()

@property (weak, nonatomic) IBOutlet UITextField *domainNameTextField;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end

@implementation NewSensorDomainViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)save:(id)sender
{
    [self.delegate createSensorDomain:self.domainNameTextField.text];
    [self cancel:self];
}
@end
