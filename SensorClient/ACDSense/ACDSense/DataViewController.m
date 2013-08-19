//
//  DataViewController.m
//  ACDSense
//
//  Created by Martin Weißbach on 8/19/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()

@property (strong, nonatomic) NSMutableArray *sensorValues;

- (void)updateTableView;

@end

@implementation DataViewController

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
    self.sensorValues = [[NSMutableArray alloc] initWithCapacity:100];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)updateTableView
{
    [self.tableView reloadData];
}

#pragma mark - Public methods

- (void)addSensorValue:(SensorValue *)sensorValue
{
    [self.sensorValues addObject:sensorValue];
    [self updateTableView];
}

- (void)addSensorValues:(NSArray *)sensorValues
{
    [self.sensorValues addObjectsFromArray:sensorValues];
    [self updateTableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sensorValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"temperatureCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    SensorValue *sensorValue = [self.sensorValues objectAtIndex:indexPath.row];
    cell.textLabel.text = sensorValue.value;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", sensorValue.unit, sensorValue.type];
    
    return cell;
}

@end
