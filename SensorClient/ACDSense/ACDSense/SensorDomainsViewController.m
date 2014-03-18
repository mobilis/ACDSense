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
#import "CoreDataStack.h"

@interface SensorDomainsViewController () <MXiMultiUserChatDiscoveryDelegate>

@property (strong) NSMutableDictionary *mucSensorDomains;
@property (strong) UIRefreshControl *refreshControl;

@property(nonatomic, strong) NSMutableArray *runningMUCDiscoveries;

@end

@implementation SensorDomainsViewController
{
    dispatch_queue_t _discoveryQueue;
}

- (void)dealloc
{
    self.mucSensorDomains = nil;
    self.refreshControl = nil;

    self.runningMUCDiscoveries = nil;

    _discoveryQueue = NULL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _discoveryQueue = dispatch_queue_create("de.tu-dresden.inf.rn.acds.discoQueue", DISPATCH_QUEUE_SERIAL);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideLoginIndicator:) name:@"loggedInTrue" object:nil];

    self.mucSensorDomains = [[CoreDataStack coreDataStack] sensorMUCs];
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
    if (self.mucSensorDomains.count == 0)
        [self.refreshControl endRefreshing];

    for (NSString *domainName in [self.mucSensorDomains allKeys])
        [self createSensorDomain:domainName];
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

- (void)hideLoginIndicator:(id)sender
{
    UIView *notificationView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 0)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    
    notificationView.backgroundColor = [UIColor lightGrayColor];
    
    label.attributedText = [[NSAttributedString alloc] initWithString:@"Login Successful" attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [notificationView addSubview:label];
    [self.view addSubview:notificationView];
    
    [UIView animateWithDuration:.25
                     animations:^{
                         CGRect viewFrame = notificationView.frame;
                         viewFrame.size.height = 44;
                         notificationView.frame = viewFrame;
                         
                         CGRect labelFrame = label.frame;
                         labelFrame.size.height = 44;
                         label.frame = labelFrame;
    }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 [UIView animateWithDuration:.25
                                                  animations:^{
                                                      CGRect viewFrame = notificationView.frame;
                                                      viewFrame.size.height = 0;
                                                      notificationView.frame = viewFrame;
                                                      
                                                      CGRect labelFrame = label.frame;
                                                      labelFrame.size.height = 0;
                                                      label.frame = labelFrame;
                                                  }
                                                  completion:^(BOOL finished) {
                                                      [notificationView removeFromSuperview];
                                                  }];
                             });
                         }
    }];
}

#pragma mark - Interface Implementation

- (void)createSensorDomain:(NSString *)domainName
{
    MXiMultiUserChatDiscovery *chatDiscovery = [MXiMultiUserChatDiscovery multiUserChatDiscoveryWithConnectionHandler:[MXiConnectionHandler sharedInstance]
                                                                                                        forDomainName:domainName
                                                                                                          andDelegate:self];
    [chatDiscovery startDiscoveryWithResultQueue:_discoveryQueue];
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
        NSString *domainName = [[self.mucSensorDomains allKeys] objectAtIndex:indexPath.row];
        NSArray *sensorMUCs = [self.mucSensorDomains objectForKey:domainName];
        for (SensorMUC *sensorMUC in sensorMUCs) {
            [[CoreDataStack coreDataStack].managedObjectContext deleteObject:sensorMUC];
        }
        self.mucSensorDomains = [[CoreDataStack coreDataStack] sensorMUCs];
        [self refreshTableView];
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
    if ([self.refreshControl isRefreshing]) [self.refreshControl endRefreshing];

//	[UIView transitionWithView:self.tableView duration:0.25f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//		[self.tableView reloadData];
//	} completion:nil];
    [self.tableView reloadData];
}

#pragma mark - UINavigationBarDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
	return UIBarPositionTopAttached;
}

#pragma mark - MXiMultiUserChatDiscoveryDelegate

- (void)multiUserChatRoomsDiscovery:(MXiMultiUserChatDiscovery *)chatDiscovery discoveredChatRooms:(NSArray *)chatRooms inDomain:(NSString *)domainName
{
    [self.runningMUCDiscoveries removeObject:chatDiscovery];

    for (MXiMultiUserChatRoom *room in chatRooms)
    {
        [SensorMUCValidator launchValidationWithConnection:[MXiConnectionHandler sharedInstance]
                                                       jid:room.jabberID.full
                                           completionBlock:^(BOOL sensorMUC, NSString *description)
                                           {
                                               if (sensorMUC && description)
                                               {
                                                   SensorMUC *muc = [SensorMUC sensorMUCwithJabberID:room.jabberID
                                                                                          domainName:domainName
                                                                                      andDescription:description];
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
