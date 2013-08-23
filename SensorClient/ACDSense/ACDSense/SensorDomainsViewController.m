//
//  SensorDomainsViewController.m
//  ACDSense
//
//  Created by Markus Wutzler on 23.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SensorDomainsViewController.h"

@interface SensorDomainsViewController ()
@property (retain) NSMutableArray *sensorDomains;

@end

@implementation SensorDomainsViewController

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
	self.sensorDomains = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.sensorDomains.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	cell.textLabel.text = [self.sensorDomains objectAtIndex:indexPath.row];
	return cell;
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

#pragma mark - UIAlertViewDelegate
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
	return [[[alertView textFieldAtIndex:0] text] length] > 0;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex > 0) {
		[self.sensorDomains addObject:[[alertView textFieldAtIndex:0] text]];
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
	}
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.sensorDomains addObject:[textField text]];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
	return YES;
}

#pragma mark - Interface Implementation
- (IBAction)addSensorDomain:(UIBarButtonItem *)sender {
	UIAlertView *newDomain = [[UIAlertView alloc] initWithTitle:@"New Domain" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add",nil];
	newDomain.alertViewStyle = UIAlertViewStylePlainTextInput;
	[[newDomain textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeURL];
	[[newDomain textFieldAtIndex:0] setDelegate:self];
	newDomain.delegate = self;
	[newDomain show];
}

@end
