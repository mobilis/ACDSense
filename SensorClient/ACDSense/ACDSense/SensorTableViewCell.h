//
//  SensorTableViewCell.h
//  ACDSense
//
//  Created by Martin Weißbach on 9/3/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SensorTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *sensorIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorValueLabel;

@end
