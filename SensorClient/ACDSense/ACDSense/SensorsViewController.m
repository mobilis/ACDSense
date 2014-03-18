//
//  SensorsViewController.m
//  ACDSense
//
//  Created by Markus Wutzler on 28.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SensorsViewController.h"
#import "SensorTableViewCell.h"

#import "DelegateSensorItems.h"

#import "Timestamp+Description.h"
#import "SensorMUC.h"
#import "MUCMessageProcessor.h"
#import "MessageProcessingException.h"

@interface SensorsViewController () <MXiMultiUserChatDelegate>

@property (nonatomic) NSMutableDictionary *multiUserChatRooms;
@property (nonatomic) NSMutableArray *connectedMUCs;

@property (strong, nonatomic) SensorMUC *selectedSensor;
@property (strong, nonatomic) NSMutableDictionary *valuesOfSelectedSensor;
@property (strong, nonatomic) NSString *selectedSubType;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *subTypeChooser;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *plotView;
@property (weak, nonatomic) IBOutlet UILabel *sensorIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorLocationLabel;

@property (strong) CPTXYGraph *graph;

- (IBAction)subTypeChosen:(UISegmentedControl*)ctrl;

- (void)constructChart;
- (void)updateChartPlot;
- (void)updateChartContent;

- (void)registerBeanListener;

- (void)sensorItemsReceived:(DelegateSensorItems *)sensorItems;

@end

@implementation SensorsViewController
{
    NSMutableDictionary *_allSensorItems;
    NSMutableDictionary *_filteredSensorItems;
    BOOL *_filtered;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.multiUserChatRooms = [NSMutableDictionary new];
    [self registerBeanListener];
	[self constructChart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Display SensorMUC

- (void)displayMultiUserChatRooms:(NSArray *)multiUserChatRooms
{
    for (SensorMUC *sensorMUC in multiUserChatRooms)
    {
        if ([self isDomainKnown:sensorMUC.domainName])
        {
            if (![[self.multiUserChatRooms objectForKey:sensorMUC.domainName] containsObject:sensorMUC])
                [[self.multiUserChatRooms objectForKey:sensorMUC.domainName] addObject:sensorMUC];
        }
        else
        {
            [self.multiUserChatRooms setObject:[@[sensorMUC] mutableCopy] forKey:sensorMUC.domainName];
        }
    }

    [self updateView];
}

- (BOOL)isDomainKnown:(NSString *)domainName
{
    return [self.multiUserChatRooms objectForKey:domainName] != nil;
}

#pragma mark - ACDSense Chat Support

- (void)connectToSensorMUC:(SensorMUC *)sensorMUC;
{
    [[MXiConnectionHandler sharedInstance].connection connectToMultiUserChatRoom:sensorMUC.jabberID.full withDelegate:self];
}

#pragma mark - MXiMultiUserChatDelegate

- (void)connectionToRoomEstablished:(NSString *)roomJID usingRoomJID:(NSString *)myRoomJID
{
    #if TARGET_IPHONE_SIMULATOR
        NSLog(@"Connection to room %@ established.", roomJID);
    #endif
    for (NSString *domainName in self.multiUserChatRooms)
        for (SensorMUC *sensorMUC in [self.multiUserChatRooms objectForKey:domainName])
            if ([sensorMUC.jabberID isEqualToJID:[XMPPJID jidWithString:roomJID]])
                [self.connectedMUCs addObject:sensorMUC];
}

- (void)didReceiveMultiUserChatMessage:(NSString *)message fromUser:(NSString *)user publishedInRoom:(NSString *)roomJID
{
    #if TARGET_IPHONE_SIMULATOR
        NSLog(@"Did receive MultiUserChat Message:\n%@", message);
    #endif
    @try {
        SensorItem *item = [[MUCMessageProcessor processJSONString:message andSensorID:roomJID] processedJSON];
        for (NSString *domain in [self.multiUserChatRooms allKeys])
            for (SensorMUC *sensorMUC in [self.multiUserChatRooms objectForKey:domain]) {
                if ([roomJID rangeOfString:sensorMUC.domainName].location != NSNotFound) {
                    item.sensorDomain = [sensorMUC copyAsSensorMUCDomain];
                    item.location = sensorMUC.location;
                }
            }
        DelegateSensorItems *delegateSensorItem = [DelegateSensorItems new];
        delegateSensorItem.sensorItems = [[NSMutableArray alloc] initWithArray:@[item]];
        if (_selectedSubType == nil)
        {
            _selectedSubType = item.type;
            @synchronized (_subTypeChooser) {
                [self.subTypeChooser removeAllSegments];
                int i=0;
                for (NSString *title in [_valuesOfSelectedSensor allKeys]) {
                    [self.subTypeChooser insertSegmentWithTitle:title atIndex:i++ animated:YES];
                }
            }
        }
        [self sensorItemsReceived:delegateSensorItem];
    }
    @catch (MessageProcessingException *exception) {
        #if TARGET_IPHONE_SIMULATOR
            NSLog(@"Exception occurred: %@, %@", exception, [exception userInfo]);
        #endif
    }
}

#pragma mark - MXiCommunication

- (void)registerBeanListener
{
    [[MXiConnectionHandler sharedInstance].connection addBeanDelegate:self
                                                         withSelector:@selector(sensorItemsReceived:)
                                                         forBeanClass:[DelegateSensorItems class]];
}

- (void)sensorItemsReceived:(DelegateSensorItems *)sensorItems
{
    if (![sensorItems isKindOfClass:[DelegateSensorItems class]]) { // just defensive programming to simplify debugging
        NSLog(@"Severe issue in the DelegateBeanMapping");
        return;
    }
    
    [self addSensorItems:sensorItems.sensorItems];
    for (SensorItem *item in sensorItems.sensorItems) {
        if (_selectedSensor && [_selectedSensor.jabberID.full isEqualToString:item.sensorId]) {
			for (SensorValue *value in item.values) {
				NSMutableArray *values = [_valuesOfSelectedSensor objectForKey:value.subType];
				if (values) {
					[values addObject:value];
				} else {
					[_valuesOfSelectedSensor setObject:[NSMutableArray arrayWithObject:value] forKey:value.subType];
				}
			}
            break;
        }
    }
	if(_selectedSensor) {
		if ([[_valuesOfSelectedSensor allKeys] count] != self.subTypeChooser.numberOfSegments)
		{
            @synchronized (_subTypeChooser) {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [self.subTypeChooser removeAllSegments];
                    int i=0;
                    for (NSString *title in [_valuesOfSelectedSensor allKeys]) {
                        [self.subTypeChooser insertSegmentWithTitle:title atIndex:i++ animated:YES];
                    }
                    self.subTypeChooser.selectedSegmentIndex = self.selectedSubType ? [[_valuesOfSelectedSensor allKeys] indexOfObject:self.selectedSubType] : UISegmentedControlNoSegment;
                });
            }

		}
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self updateChartContent];
        });
	}
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
            NSMutableArray *storedItems = [NSMutableArray arrayWithArray:[_filteredSensorItems objectForKey:sensorItem.sensorDomain.domainId]];
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

- (void)updateView
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.multiUserChatRooms allKeys].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[self.multiUserChatRooms allKeys] objectAtIndex:section];
    return [((NSArray *)[self.multiUserChatRooms objectForKey:key]) count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    return [[self.multiUserChatRooms allKeys] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sensorItemCell";
    SensorTableViewCell *cell = (SensorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SensorTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    NSString *key = [[self.multiUserChatRooms allKeys] objectAtIndex:indexPath.section];
    SensorMUC *sensorMUC = [[self.multiUserChatRooms objectForKey:key] objectAtIndex:indexPath.row];

    cell.sensorIDLabel.text = sensorMUC.jabberID.full;
    cell.sensorDetailLabel.text = [sensorMUC type];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self.multiUserChatRooms allKeys] objectAtIndex:indexPath.section];
    SensorMUC *sensorMUC = [[self.multiUserChatRooms objectForKey:key] objectAtIndex:indexPath.row];
    [self connectToSensorMUC:sensorMUC];

	self.sensorIDLabel.text = [sensorMUC.jabberID full];
    self.sensorTypeLabel.text = [sensorMUC type];
    self.sensorLocationLabel.text = [sensorMUC location].locationName;
    [self.mapView removeAnnotations:self.mapView.annotations];
	MKPointAnnotation *pa = [MKPointAnnotation new];
	pa.coordinate = CLLocationCoordinate2DMake((double) sensorMUC.location.latitude, (double) sensorMUC.location.longitude);
	[self.mapView addAnnotation:pa];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([pa coordinate], 100000, 100000);
	[self.mapView setRegion:region animated:YES];
	[self.mapView selectAnnotation:pa animated:YES];

	self.selectedSensor = sensorMUC;
	self.valuesOfSelectedSensor = [NSMutableDictionary new];
    for (SensorItem *sensorItem in [_allSensorItems objectForKey:[sensorMUC copyAsSensorMUCDomain].domainId]) {
        for (SensorValue *value in sensorItem.values) {
            NSMutableArray *values = [_valuesOfSelectedSensor objectForKey:value.subType];
            if (values) {
                [values addObject:value];
            } else {
                [_valuesOfSelectedSensor setObject:[NSMutableArray arrayWithObject:value] forKey:value.subType];
            }
        }
    }
//    self.selectedSubType = [[_valuesOfSelectedSensor allKeys] firstObject];
//	[self.subTypeChooser removeAllSegments];
//	int i=0;
//	for (NSString *title in [_valuesOfSelectedSensor allKeys]) {
//		[self.subTypeChooser insertSegmentWithTitle:title atIndex:i++ animated:YES];
//	}
	[self updateChartPlot];
	[self updateChartContent];
}
#pragma mark - Construct Chart
- (void)constructChart
{
    self.graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    [self.graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    self.plotView.hostedGraph = _graph;
	_graph.plotAreaFrame.cornerRadius = 0.f;
	_graph.plotAreaFrame.shadowRadius = 0.f;
	_graph.borderLineStyle = nil;
	_graph.plotAreaFrame.borderLineStyle = nil;
	
	[_graph.plotAreaFrame setPaddingTop:10.0f];
    [_graph.plotAreaFrame setPaddingRight:10.0f];
    [_graph.plotAreaFrame setPaddingBottom:10.0f];
    [_graph.plotAreaFrame setPaddingLeft:15.0f];
    
    _graph.paddingBottom = 0.0;
    _graph.paddingLeft = 0.0;
    _graph.paddingRight = 0.0;
    _graph.paddingTop = 0.0;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0)
                                                    length:CPTDecimalFromFloat(10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0)
                                                    length:CPTDecimalFromFloat(5.0)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    CPTXYAxis *xAxis = axisSet.xAxis;
    xAxis.majorIntervalLength = CPTDecimalFromString(@"1.0");
    xAxis.minorTicksPerInterval = 5;
	xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:30.0];
	xAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
	xAxis.preferredNumberOfMajorTicks = 4;

    
    CPTXYAxis *yAxis = axisSet.yAxis;
    yAxis.majorIntervalLength = CPTDecimalFromString(@"1.0");
    yAxis.minorTicksPerInterval = 1;
	yAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;
	yAxis.preferredNumberOfMajorTicks = 4;
	
	yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:50.0];
    
    [self updateChartPlot];
}

#pragma mark - Private Methods

- (void)updateChartContent
{
    [_graph reloadData];
	[_graph.defaultPlotSpace scaleToFitPlots:_graph.allPlots];
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace*)_graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(-1) length:CPTDecimalFromInteger([[_valuesOfSelectedSensor objectForKey:_selectedSubType] count] + 2)];
	
	double min = DBL_MAX;
	double max = DBL_MIN;
	for (SensorValue *value in [_valuesOfSelectedSensor objectForKey:_selectedSubType])
	{
		if ([value.value doubleValue] > max)
			max = [value.value doubleValue];
		if ([value.value doubleValue] < min)
			min = [value.value doubleValue];
	}
	if ((max-min) > 1.0) {
		plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(min-0.1*(max-min)) length:CPTDecimalFromDouble(1.2*(max-min))];
	} else {
		double median = [[_valuesOfSelectedSensor objectForKey:_selectedSubType] count] == 0 ? 0 : min+((max-min)/2);
		plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(median-1) length:CPTDecimalFromDouble(2)];
	}
	
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    CPTXYAxis *xAxis = axisSet.xAxis;
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
	dateFormatter.timeStyle = kCFDateFormatterMediumStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
	SensorValue *origin = [[_valuesOfSelectedSensor objectForKey:_selectedSubType] firstObject];
    timeFormatter.referenceDate = [origin.timestamp timestampAsDate];
    xAxis.labelFormatter = timeFormatter;
}

- (void)updateChartPlot
{
    NSArray *plots = [_graph allPlots];
    for (CPTPlot *plot in plots) {
        [_graph removePlot:plot];
    }
    
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Black Plot";
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 3.f;
    lineStyle.lineColor = [CPTColor blackColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
	
    dataSourceLinePlot.dataSource = self;
    [_graph addPlot:dataSourceLinePlot];
}

#pragma mark - CPTPlotDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if (_selectedSensor)
		return ((NSArray*)[_valuesOfSelectedSensor objectForKey:_selectedSubType]).count;
	return 0;
}

- (double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    if (![_valuesOfSelectedSensor objectForKey:_selectedSubType]) {
        return 0.0;
    }
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX: {
            return [[NSNumber numberWithInt:idx] doubleValue];
        }
        case CPTScatterPlotFieldY: {
            SensorValue *value = [[_valuesOfSelectedSensor objectForKey:_selectedSubType] objectAtIndex:idx];
            return [value.value doubleValue];
        }
        default:
            break;
    }
    return 0.0;
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    if (![_valuesOfSelectedSensor objectForKey:_selectedSubType]) {
        return NULL;
    }
    int mod  = ((int)[[_valuesOfSelectedSensor objectForKey:_selectedSubType] count] / 10)+1;
	if (idx % mod != 0) {
		return NULL;
	}
    SensorValue *value = [[_valuesOfSelectedSensor objectForKey:_selectedSubType] objectAtIndex:idx];
	
    CPTMutableTextStyle *labelStyle = [[CPTMutableTextStyle alloc] init];
	labelStyle.color = [CPTColor blackColor];
    CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithText:value.value
                                                       textStyle:labelStyle];
    
    return [axisLabel contentLayer];
}

#pragma mark - SubTypeChooser
- (void)subTypeChosen:(UISegmentedControl *)ctrl
{
	self.selectedSubType = [[_valuesOfSelectedSensor allKeys] objectAtIndex:ctrl.selectedSegmentIndex];
	[self updateChartContent];
}

#pragma mark - UINavigationBarDelegate
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
	return UIBarPositionTopAttached;
}

@end
