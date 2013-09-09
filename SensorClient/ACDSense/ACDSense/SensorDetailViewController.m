//
//  SensorDetailViewController.m
//  ACDSense
//
//  Created by Martin Weißbach on 9/1/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SensorDetailViewController.h"

#import "SensorValue.h"
#import "Location+Description.h"
#import "Timestamp+Description.h"

@interface SensorDetailViewController ()

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *plotView;
@property (weak, nonatomic) IBOutlet UILabel *sensorIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorLocationLabel;

@property (strong) CPTXYGraph *graph;

@property (strong, nonatomic) NSMutableArray *sensorValues;

- (void)constructChart;
- (void)updateChartPlot;
- (void)updateChartContent;
- (void)updateLabels;

@end

@implementation SensorDetailViewController

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
    
    [self constructChart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)constructChart
{
    self.graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    [self.graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    self.plotView.hostedGraph = _graph;
    
    _graph.paddingBottom = 10.0;
    _graph.paddingLeft = 10.0;
    _graph.paddingRight = 10.0;
    _graph.paddingTop = 10.0;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0)
                                                    length:CPTDecimalFromFloat(10.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0)
                                                    length:CPTDecimalFromFloat(5.0)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    CPTXYAxis *xAxis = axisSet.xAxis;
    xAxis.majorIntervalLength = CPTDecimalFromString(@"10.0");
    xAxis.minorTicksPerInterval = 5;
    
    CPTXYAxis *yAxis = axisSet.yAxis;
    yAxis.majorIntervalLength = CPTDecimalFromString(@"1.0");
    yAxis.minorTicksPerInterval = 1;
    
    [self updateChartPlot];
}

#pragma mark - Custom Setter & Getter

- (void)setSensorItem:(SensorItem *)sensorItem
{
    if (_sensorItem == sensorItem) {
        return;
    }
    _sensorItem = nil;
    _sensorItem = sensorItem;
    
    self.sensorValues = [NSMutableArray arrayWithArray:_sensorItem.values];
    
    [self updateLabels];
    [self updateChartContent];
}

#pragma mark - Private Methods

- (void)updateChartContent
{
    [_graph reloadData];
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
    lineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.0f],[NSNumber numberWithFloat:5.0f], nil];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [_graph addPlot:dataSourceLinePlot];
}

- (void)updateLabels
{
    _sensorIDLabel.text = _sensorItem.sensorId;
    _sensorTypeLabel.text = _sensorItem.type;
    _sensorLocationLabel.text = [_sensorItem.location locationAsString];
}

#pragma mark - Public Methods

- (void)addSensorValues:(NSArray *)sensorValues
{
    if (!_sensorValues) {
        self.sensorValues = [NSMutableArray arrayWithCapacity:sensorValues.count + 10];
    }
    
    [_sensorValues addObjectsFromArray:sensorValues];
    [self updateChartContent];
}

#pragma mark - CPTPlotDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return _sensorValues ? _sensorValues.count : 0;
}

- (double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    if (!_sensorValues) {
        return 0.0;
    }
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX: {
            return [[NSNumber numberWithInt:idx] doubleValue];
        }
        case CPTScatterPlotFieldY: {
            SensorValue *value = [_sensorValues objectAtIndex:idx];
            return [value.value doubleValue];
        }
        default:
            break;
    }
    return 0.0;
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    if (!_sensorValues) {
        return NULL;
    }
    
    SensorValue *value = [_sensorValues objectAtIndex:idx];
    Timestamp *timestamp = value.timestamp;

    CPTTextStyle *labelStyle = [[CPTTextStyle alloc] init];
    CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithText:[timestamp timestampAsString]
                                                       textStyle:labelStyle];
    
    return [axisLabel contentLayer];
}

#pragma mark - CPTPlotSpaceDelegate



@end
