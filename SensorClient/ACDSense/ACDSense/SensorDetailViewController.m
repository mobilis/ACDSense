//
//  SensorDetailViewController.m
//  ACDSense
//
//  Created by Martin Weißbach on 9/1/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SensorDetailViewController.h"

@interface SensorDetailViewController ()

@property (weak, nonatomic) IBOutlet CPTGraphHostingView *plotView;

@property (strong) CPTXYGraph *graph;

@property (strong, nonatomic) NSMutableArray *sensorValues;

- (void)constructChart;

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
//    xAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"5.0");
    xAxis.minorTicksPerInterval = 5;
    
    CPTXYAxis *yAxis = axisSet.xAxis;
    yAxis.majorIntervalLength = CPTDecimalFromString(@"10.0");
//    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"5.0");
    yAxis.minorTicksPerInterval = 5;
    
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Black Plot";
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 3.f;
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.0f],[NSNumber numberWithFloat:5.0f], nil];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
}

#pragma mark - CPTPlotDataSource

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return _sensorValues ? _sensorValues.count : 0;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    return  [NSNumber numberWithInt:5];
}

@end
