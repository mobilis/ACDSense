//
//  SensorChooserViewController.m
//  ACDSense
//
//  Created by Martin Weißbach on 9/1/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SensorChooserViewController.h"

#import "SensorItem.h"

@interface SensorChooserViewController ()

@property (strong, nonatomic) NSMutableDictionary *sensorItems;

- (void)updateView;

@end

@implementation SensorChooserViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

- (void)addSensorItems:(NSArray *)sensorItems
{
    if (!sensorItems || sensorItems.count == 0) {
        return;
    }
    if (!_sensorItems) {
        self.sensorItems = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    for (SensorItem *sensorItem in sensorItems) {
        if (_sensorItems ) {
            SensorItem *tempSensorItem = [_sensorItems objectForKey:sensorItem.sensorId];
            if (tempSensorItem) {
                [tempSensorItem.values addObjectsFromArray:sensorItem.values];
            } else {
                tempSensorItem = sensorItem;
            }
            [_sensorItems setObject:tempSensorItem forKey:tempSensorItem.sensorId];
            break;
        }
    }
    [self updateView];
}

#pragma mark - Private Methods

- (void)updateView
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sensorItems ? [_sensorItems count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sensorItemCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString *sensorItemKey = [[_sensorItems allKeys] objectAtIndex:indexPath.row]; // TODO: sort to guarantee a fixed order
    SensorItem *sensorItem = [_sensorItems objectForKey:sensorItemKey];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Sensor ID: %@", sensorItem.sensorId];
    cell.detailTextLabel.text = sensorItem.type;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: implement delegation to display this sensor in the detail view
}
@end
