//
//  SensorDomainsViewController.m
//  ACDSense
//
//  Created by Markus Wutzler on 23.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SensorDomainsViewController.h"
#import "SensorsViewController.h"
#import "CreateSensorMUCDomain.h"
#import "NewSensorDomainViewController.h"
#import "MXiMultiUserChatDiscovery.h"
#import "MXiMultiUserChatRoom.h"
#import "SensorMUCValidator.h"
#import "SensorMUC.h"

@interface SensorDomainsViewController () <MXiMultiUserChatDiscoveryDelegate>

@property (strong) NSMutableDictionary *mucSensorDomains;
@property (strong) UIRefreshControl *refreshControl;

@property(nonatomic, strong) NSMutableArray *runningMUCDiscoveries;

@end

@implementation SensorDomainsViewController

- (void)dealloc
{
    self.mucSensorDomains = nil;
    self.refreshControl = nil;

    self.runningMUCDiscoveries = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mucSensorDomains = [NSMutableDictionary new];
    self.runningMUCDiscoveries = [[NSMutableArray alloc] initWithCapacity:5];

	self.refreshControl = [UIRefreshControl new]; // TODO: use this refresh control to relaunch service discovery to detect MUCs for domain.
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
}

- (void)viewWillAppear:(BOOL)animated
{
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

#pragma mark - Interface Implementation

- (void)createSensorDomain:(NSString *)domainName fetchingFromService:(BOOL)fetchingRemote
{
    MXiMultiUserChatDiscovery *chatDiscovery = [MXiMultiUserChatDiscovery multiUserChatDiscoveryWithConnectionHandler:[MXiConnectionHandler sharedInstance]
                                                                                                        forDomainName:domainName
                                                                                                          andDelegate:self];
    [chatDiscovery startDiscoveryWithResultQueue:dispatch_get_main_queue()];
    [self.runningMUCDiscoveries addObject:chatDiscovery];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mucSensorDomains.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.textLabel.text = [[self.mucSensorDomains allKeys] objectAtIndex:indexPath.row];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Multi User Chat Rooms";
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete == editingStyle)
    {
        // TODO: delete the MUC domain, close connections to MUC and remove them from the detail view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *domainName = [[self.mucSensorDomains allKeys] objectAtIndex:indexPath.row];
    NSArray *multiUserChatRooms = [self.mucSensorDomains objectForKey:domainName];
    SensorsViewController *detailView = [((UISplitViewController *)self.parentViewController.parentViewController) viewControllers][1];
    [detailView displayMultiUserChatRooms: multiUserChatRooms];
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
                                                   if ([self isDomainKnown:muc.domainName])
                                                   {
                                                       [[self.mucSensorDomains objectForKey:muc.domainName] addObject:muc];
                                                   }
                                                   else
                                                   {
                                                       [self.mucSensorDomains setObject:[@[muc] mutableCopy] forKey:muc.domainName];
                                                   }
                                                   dispatch_async(dispatch_get_main_queue(), ^
                                                   {
                                                       [self refreshTableView];
                                                   });
                                               }
                                           }];
    }
}

- (BOOL)isDomainKnown:(NSString *)domainName
{
    return [self.mucSensorDomains objectForKey:domainName] != nil;
}

@end
