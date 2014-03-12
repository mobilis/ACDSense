//
//  SensorDomainsViewController.h
//  ACDSense
//
//  Created by Markus Wutzler on 23.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SensorDomainsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UITextFieldDelegate, UINavigationBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

- (void)createSensorDomain:(NSString *)domainName;

@end
