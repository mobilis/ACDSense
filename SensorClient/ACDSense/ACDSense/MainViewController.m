//
//  MainViewController.m
//  ACDSense
//
//  Created by Markus Wutzler on 23.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

- (void)awakeFromNib
{
	self.delegate = self;
}

#pragma mark - UISplitViewControllerDelegate
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
	return NO;
}

#pragma mark - UIViewController

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
	return YES;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
	return YES;
}

@end
