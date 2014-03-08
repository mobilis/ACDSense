//
//  SensorDomainsViewController.m
//  ACDSense
//
//  Created by Markus Wutzler on 23.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SensorDomainsViewController.h"

#import "SensorsViewController.h"

#import "SensorMUCDomain.h"

#import "CreateSensorMUCDomain.h"
#import "RemoveSensorMUCDomain.h"
#import "SensorMUCDomainCreated.h"
#import "SensorMUCDomainRemoved.h"
#import "GetSensorMUCDomainsRequest.h"
#import "GetSensorMUCDomainsResponse.h"
#import "NewSensorDomainViewController.h"
#import "MXiMultiUserChatDiscovery.h"
#import "MXiMultiUserChatRoom.h"
#import "SensorMUCValidator.h"
#import "SensorMUC.h"

typedef enum
{
    REMOTE_DOMAINS,
    MUC_DOMAINS
} TableSections;

@interface SensorDomainsViewController () <MXiMultiUserChatDiscoveryDelegate>

@property (strong) NSMutableArray *sensorDomains;
@property (strong) NSMutableArray *mucSensorDomains;
@property (strong) UIRefreshControl *refreshControl;

@property(nonatomic, strong) NSMutableArray *runningMUCDiscoveries;

- (void) sensorMUCDomainCreated:(SensorMUCDomainCreated *) bean;
- (void) sensorMUCDomainRemoved:(SensorMUCDomainRemoved *) bean;
- (void) sensorMUCDomainsReceived:(GetSensorMUCDomainsResponse *) bean;

@end

@implementation SensorDomainsViewController

- (void)dealloc
{
    [[MXiConnectionHandler sharedInstance].connection removeBeanDelegate:self forBeanClass:[SensorMUCDomainCreated class]];
    [[MXiConnectionHandler sharedInstance].connection removeBeanDelegate:self forBeanClass:[SensorMUCDomainRemoved class]];
    [[MXiConnectionHandler sharedInstance].connection removeBeanDelegate:self forBeanClass:[GetSensorMUCDomainsResponse class]];
    
    self.sensorDomains = nil;
    self.mucSensorDomains = nil;
    self.refreshControl = nil;

    self.runningMUCDiscoveries = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.sensorDomains = [NSMutableArray new];
    self.mucSensorDomains = [NSMutableArray new];
    self.runningMUCDiscoveries = [[NSMutableArray alloc] initWithCapacity:5];

    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self
                                                         withSelector:@selector(sensorMUCDomainCreated:)
                                                         forBeanClass:[SensorMUCDomainCreated class]];
    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self
                                                         withSelector:@selector(sensorMUCDomainRemoved:)
                                                         forBeanClass:[SensorMUCDomainRemoved class]];
    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self
                                                         withSelector:@selector(sensorMUCDomainsReceived:)
                                                         forBeanClass:[GetSensorMUCDomainsResponse class]];
	
	self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self.tableView setAllowsMultipleSelection:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.runningMUCDiscoveries removeAllObjects];
}

- (void)handleRefresh:(id)arg
{
	[[MXiConnectionHandler sharedInstance] sendBean:[GetSensorMUCDomainsRequest new] toService:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([MXiConnectionHandler sharedInstance].serviceManager.services.count == 1)
        [[MXiConnectionHandler sharedInstance] sendBean:[GetSensorMUCDomainsRequest new] toService:nil];
	[super viewWillAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"newSensorDomain"])
    {
        NewSensorDomainViewController *controller = (NewSensorDomainViewController *)segue.destinationViewController;
        controller.delegate = self;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == REMOTE_DOMAINS) return self.sensorDomains.count;
    else if (section == MUC_DOMAINS) return self.mucSensorDomains.count;
    else return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.textLabel.text = ((SensorMUCDomain *)[self.sensorDomains objectAtIndex:indexPath.row]).domainURL;
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == REMOTE_DOMAINS) return @"Service Managed Domains";
    else if (section == MUC_DOMAINS) return @"Direct Access MUC";
    else return @"";
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
	[[MXiConnectionHandler sharedInstance] sendBean:request toService:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    SensorsViewController *detailView = [((UISplitViewController *)self.parentViewController.parentViewController) viewControllers][1];
    NSMutableArray *selectedDomains = [NSMutableArray arrayWithCapacity:selectedRows.count];

    for (NSIndexPath *indexPath in selectedRows) {
        [selectedDomains addObject:[_sensorDomains objectAtIndex:indexPath.row]];
    }
    [detailView filterForDomains:selectedDomains];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	CreateSensorMUCDomain *request = [CreateSensorMUCDomain new];
	SensorMUCDomain *domain = [SensorMUCDomain new];
	domain.domainId = [[NSUUID UUID] UUIDString];
	domain.domainURL = [textField text];
	request.sensorDomain = domain;
	[[MXiConnectionHandler sharedInstance] sendBean:request toService:nil];
	return YES;
}

#pragma mark - Interface Implementation

- (void)createSensorDomain:(NSString *)domainName fetchingFromService:(BOOL)fetchingRemote
{
    if (fetchingRemote)
    {
        CreateSensorMUCDomain *request = [CreateSensorMUCDomain new];
        SensorMUCDomain *domain = [SensorMUCDomain new];
        domain.domainId = [[NSUUID UUID] UUIDString];
        domain.domainURL = domainName;
        request.sensorDomain = domain;
        [[MXiConnectionHandler sharedInstance] sendBean:request toService:nil];
    }
    else
    {
        MXiMultiUserChatDiscovery *multiUserChatDiscovery = [MXiMultiUserChatDiscovery multiUserChatDiscoveryWithConnectionHandler:[MXiConnectionHandler sharedInstance]
                                                                                                                     forDomainName:domainName
                                                                                                                       andDelegate:self];
        [self.runningMUCDiscoveries addObject:multiUserChatDiscovery];
        [multiUserChatDiscovery startDiscoveryWithResultQueue:dispatch_get_main_queue()];
    }
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

#pragma mark - MXiMultiUserChatDiscoveryDelegate

- (void)multiUserChatRoomsDiscovered:(NSArray *)chatRooms inDomain:(NSString *)domainName
{
    for (MXiMultiUserChatRoom *room in chatRooms)
    {
        [SensorMUCValidator launchValidationWithConnection:[MXiConnectionHandler sharedInstance]
                                                       jid:room.jabberID.full
                                           completionBlock:^(BOOL sensorMUC, NSString *description)
                                           {
                                               if (sensorMUC && description)
                                               {
                                                   SensorMUC *muc = [[SensorMUC alloc] initWithJabberID:room.jabberID domainName:domainName andDescription:description];
                                                   [self.mucSensorDomains addObject:[muc copyAsSensorMUCDomain]];
                                                   dispatch_async(dispatch_get_main_queue(), ^
                                                   {
                                                       SensorsViewController *detailView = [((UISplitViewController *) self.parentViewController.parentViewController) viewControllers][1];
                                                       [detailView connectToSensorMUC:muc];
                                                       
                                                       [self refreshTableView];
                                                   });
                                               }
                                           }];
    }
}

@end
