//
//  SensorDomainsViewController.m
//  ACDSense
//
//  Created by Markus Wutzler on 23.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SensorDomainsViewController.h"

#import "SensorsViewController.h"

#import "ConnectionHandler.h"

#import "SensorMUCDomain.h"

#import "CreateSensorMUCDomain.h"
#import "RemoveSensorMUCDomain.h"
#import "SensorMUCDomainCreated.h"
#import "SensorMUCDomainRemoved.h"
#import "GetSensorMUCDomainsRequest.h"
#import "GetSensorMUCDomainsResponse.h"

@interface SensorDomainsViewController ()
@property (retain) NSMutableArray *sensorDomains;
@property (retain) UIRefreshControl *refreshControl;

- (void) sensorMUCDomainCreated:(SensorMUCDomainCreated *) bean;
- (void) sensorMUCDomainRemoved:(SensorMUCDomainRemoved *) bean;
- (void) sensorMUCDomainsReceived:(GetSensorMUCDomainsResponse *) bean;
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
	[[ConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(sensorMUCDomainCreated:) forBeanClass:[SensorMUCDomainCreated class]];
	[[ConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(sensorMUCDomainRemoved:) forBeanClass:[SensorMUCDomainRemoved class]];
	[[ConnectionHandler sharedInstance] addDelegate:self withSelector:@selector(sensorMUCDomainsReceived:) forBeanClass:[GetSensorMUCDomainsResponse class]];
	
	self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView setAllowsMultipleSelection:YES];
}

- (void)handleRefresh:(id)arg
{
	[[ConnectionHandler sharedInstance] sendBean:[GetSensorMUCDomainsRequest new]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[ConnectionHandler sharedInstance] sendBean:[GetSensorMUCDomainsRequest new]];
	[super viewWillAppear:animated];
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
	cell.textLabel.text = ((SensorMUCDomain *)[self.sensorDomains objectAtIndex:indexPath.row]).domainURL;
	return cell;
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	RemoveSensorMUCDomain *request = [RemoveSensorMUCDomain new];
	request.sensorDomain = [self.sensorDomains objectAtIndex:indexPath.row];
	[[ConnectionHandler sharedInstance] sendBean:request];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SensorsViewController *detailView = [((UISplitViewController *)self.parentViewController.parentViewController) viewControllers][1];
    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    NSMutableArray *selectedDomains = [NSMutableArray arrayWithCapacity:selectedRows.count];
    
    for (NSIndexPath *indexPath in selectedRows) {
        [selectedDomains addObject:[_sensorDomains objectAtIndex:indexPath.row]];
    }
    [detailView filterForDomains:selectedDomains];
}

#pragma mark - UIAlertViewDelegate
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
	return [[[alertView textFieldAtIndex:0] text] length] > 0;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex > 0) {
		CreateSensorMUCDomain *request = [CreateSensorMUCDomain new];
		SensorMUCDomain *domain = [SensorMUCDomain new];
		domain.domainId = [[NSUUID UUID] UUIDString];
		domain.domainURL = [[alertView textFieldAtIndex:0] text];
		request.sensorDomain = domain;
		[[ConnectionHandler sharedInstance] sendBean:request];
	}
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	CreateSensorMUCDomain *request = [CreateSensorMUCDomain new];
	SensorMUCDomain *domain = [SensorMUCDomain new];
	domain.domainId = [[NSUUID UUID] UUIDString];
	domain.domainURL = [textField text];
	request.sensorDomain = domain;
	[[ConnectionHandler sharedInstance] sendBean:request];
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

- (void)sensorMUCDomainCreated:(SensorMUCDomainCreated *)bean
{
	[self.sensorDomains addObject:bean.sensorDomain];
	[self refreshTableView];
}

- (void)sensorMUCDomainRemoved:(SensorMUCDomainRemoved *)bean
{
	for (SensorMUCDomain *domain in self.sensorDomains) {
		if ([[domain domainId] isEqualToString:bean.sensorDomain.domainId]) {
			[self.sensorDomains removeObject:domain];
			break;
		}
	}
	[self refreshTableView];
}

- (void)sensorMUCDomainsReceived:(GetSensorMUCDomainsResponse *)bean
{
	[self.sensorDomains removeAllObjects];
	[self.sensorDomains addObjectsFromArray:bean.sensorDomains];
	[self.refreshControl endRefreshing];
	[self refreshTableView];
}

- (void)refreshTableView
{
	[UIView transitionWithView:self.tableView duration:0.25f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[self.tableView reloadData];
	} completion:nil];
}

#pragma mark - UINavigationBarDelegate
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
	return UIBarPositionTopAttached;
}

@end
