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
- (void)updateMapView;

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
    [self.graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.plotView.hostedGraph = _graph;
	_graph.plotAreaFrame.cornerRadius = 0.f;
	_graph.plotAreaFrame.shadowRadius = 0.f;
	
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
    
    CPTXYAxis *yAxis = axisSet.yAxis;
    yAxis.majorIntervalLength = CPTDecimalFromString(@"1.0");
    yAxis.minorTicksPerInterval = 1;
	yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:50.0];
    
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
	[self updateMapView];
}

#pragma mark - Private Methods

- (void)updateMapView
{
	[self.mapView removeAnnotations:self.mapView.annotations];
	MKPointAnnotation *pa = [MKPointAnnotation new];
	pa.coordinate = CLLocationCoordinate2DMake((double) self.sensorItem.location.latitude, (double) self.sensorItem.location.longitude);
	[self.mapView addAnnotation:pa];
}

- (void)updateChartContent
{
    [_graph reloadData];
	[_graph.defaultPlotSpace scaleToFitPlots:_graph.allPlots];
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace*)_graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(-1) length:CPTDecimalFromInteger(self.sensorValues.count + 2)];

	double min = DBL_MAX;
	double max = DBL_MIN;
	for (SensorValue *value in self.sensorValues)
	{
		if ([value.value doubleValue] > max)
			max = [value.value doubleValue];
		if ([value.value doubleValue] < min)
			min = [value.value doubleValue];
	}
	if (max != min) {
		plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(min-0.1*(max-min)) length:CPTDecimalFromDouble(1.2*(max-min))];
	} else {
		plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(max-1) length:CPTDecimalFromDouble(2)];
	}
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
    lineStyle.lineColor = [CPTColor lightGrayColor];
//    lineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.0f],[NSNumber numberWithFloat:5.0f], nil];
    dataSourceLinePlot.dataLineStyle = lineStyle;
	dataSourceLinePlot.labelRotation = 1.571f/2;
	
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.textAlignment = CPTTextAlignmentRight;
	dataSourceLinePlot.labelTextStyle = textStyle;

    
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

    CPTMutableTextStyle *labelStyle = [[CPTMutableTextStyle alloc] init];
	labelStyle.color = [CPTColor lightGrayColor];
    CPTAxisLabel *axisLabel = [[CPTAxisLabel alloc] initWithText:[timestamp timestampAsString]
                                                       textStyle:labelStyle];
    
    return [axisLabel contentLayer];
}

#pragma mark - CPTPlotSpaceDelegate

#pragma mark - MKMapViewDelegate
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 100000, 100000);
	[mapView setRegion:region animated:YES];
	[mapView selectAnnotation:mp animated:YES];
}

@end
