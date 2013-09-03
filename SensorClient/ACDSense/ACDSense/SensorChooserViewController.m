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

@property (strong, nonatomic) NSMutableDictionary *filteredSensorItems;
@property (strong, nonatomic) NSMutableDictionary *allSensorItems;
@property BOOL filtered;

- (void)updateView;
- (SensorItem *)retrieveSensorItemAtIndexPath:(NSIndexPath *)indexPath;

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
    
    self.allSensorItems = [NSMutableDictionary dictionaryWithCapacity:10];
    self.filteredSensorItems = [NSMutableDictionary dictionaryWithCapacity:10];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public Methods

- (void)filterForSensorMUCDomains:(NSArray *)domains
{
    if (!domains || domains.count == 0) {
        _filtered = NO;
        return;
    }
    
    self.filteredSensorItems = [NSMutableDictionary dictionaryWithCapacity:domains.count];
    for (NSString *domainID in [_allSensorItems allKeys]) {
        for (SensorMUCDomain *domain in domains) {
            if ([domain.domainId isEqualToString:domainID]) {
                [self.filteredSensorItems setObject:[_allSensorItems objectForKey:domainID] forKey:domainID];
            }
        }
    }
    
    _filtered = YES;
    [self updateView];
}

- (void)addSensorItems:(NSArray *)sensorItems
{
    if (!sensorItems || sensorItems.count == 0) {
        return;
    }
    
    for (SensorItem *sensorItem in sensorItems) {
        NSMutableArray *storedItems = [NSMutableArray arrayWithArray:[_allSensorItems objectForKey:sensorItem.sensorDomain.domainId]];
        if (storedItems) {
            BOOL found = NO;
            for (SensorItem *storedSensorItem in storedItems) {
                if ([sensorItem.sensorId isEqualToString:storedSensorItem.sensorId]) {
                    [storedSensorItem.values addObjectsFromArray:sensorItem.values];
                    found = YES;
                    break;
                }
            }
            if (!found) {
                [storedItems addObject:sensorItem];
                [_allSensorItems setObject:storedItems forKey:sensorItem.sensorDomain.domainId];
            }
        } else {
            [_allSensorItems setObject:@[sensorItem] forKey:sensorItem.sensorDomain.domainId];
        }
    }
    if (_filtered) {
        for (SensorItem *sensorItem in sensorItems) {
            NSMutableArray *storedItems = [_filteredSensorItems objectForKey:sensorItem.sensorDomain.domainId];
            if (storedItems) {
                BOOL found = NO;
                for (SensorItem *storedSensorItem in storedItems) {
                    if ([sensorItem.sensorId isEqualToString:storedSensorItem.sensorId]) {
                        [storedSensorItem.values addObjectsFromArray:sensorItem.values];
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    [storedItems addObject:sensorItem];
                    [_filteredSensorItems setObject:storedItems forKey:sensorItem.sensorDomain.domainId];
                }
            } else {
                [_filteredSensorItems setObject:@[sensorItem] forKey:sensorItem.sensorDomain.domainId];
            }
        }
    }
    [self updateView];
}

#pragma mark - Private Methods

- (void)updateView
{
    [self.tableView reloadData];
}

- (SensorItem *)retrieveSensorItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sensorItemKey = nil;
    if (_filtered) {
        sensorItemKey = [[_filteredSensorItems allKeys] objectAtIndex:indexPath.section];
        return [[_filteredSensorItems objectForKey:sensorItemKey] objectAtIndex:indexPath.row];
    } else {
        sensorItemKey = [[_allSensorItems allKeys] objectAtIndex:indexPath.section];
        return [[_allSensorItems objectForKey:sensorItemKey] objectAtIndex:indexPath.row];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_filtered) {
        return [[_filteredSensorItems allKeys] count];
    } else {
        return [[_allSensorItems allKeys] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *items = nil;
    if (_filtered) {
        items = [_filteredSensorItems objectForKey:[[_filteredSensorItems allKeys] objectAtIndex:section]];
    } else {
        items = [_allSensorItems objectForKey:[[_allSensorItems allKeys] objectAtIndex:section]];
    }
    return items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key = nil;
    NSArray *items = nil;
    if (_filtered) {
        key = [[_filteredSensorItems allKeys] objectAtIndex:section];
        items = [_filteredSensorItems objectForKey:key];
    } else {
        key = [[_allSensorItems allKeys] objectAtIndex:section];
        items = [_allSensorItems objectForKey:key];
    }
    return ((SensorItem *)items[0]).sensorDomain.domainURL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sensorItemCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SensorItem *sensorItem = [self retrieveSensorItemAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Sensor ID: %@", sensorItem.sensorId];
    cell.detailTextLabel.text = sensorItem.type;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate) {
        [_delegate performSelector:@selector(updateSensorItemWithSensorItem:)
                        withObject:[self retrieveSensorItemAtIndexPath:indexPath]];
    }
}
@end
