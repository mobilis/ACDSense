//
//  SettingsViewController.m
//  ACDSense
//
//  Created by Markus Wutzler on 23.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <MXi/MXiConnectionHandler.h>
#import "SettingsViewController.h"
#import "TextFieldCell.h"

#import "AccountManager.h"

@interface SettingsViewController ()
@property (retain) NSString *jid;
@property (retain) NSString *password;
@property (retain) NSString *hostName;
@property (retain) NSNumber *port;

@property (weak) UITextField *jidField;
@property (weak) UITextField *passwordField;
@property (weak) UITextField *hostNameField;
@property (weak) UITextField *portField;

- (void) saveSettings;
@end

@implementation SettingsViewController

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
	// Do any additional setup after loading the view.    
    Account *account = [AccountManager account];
    
    self.jid = account.jid;
    self.password = account.password;
    self.hostName = account.hostName;
    self.port = account.port;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self saveSettings];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldCell" forIndexPath:indexPath];
	UITextField *tf = cell.textField;
	tf.delegate = self;
	tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
	tf.autocorrectionType = UITextAutocorrectionTypeNo;
	switch (indexPath.section) {
		case 0:
			self.hostNameField = tf;
			tf.keyboardType = UIKeyboardTypeURL;
			tf.text = self.hostName;
			break;
		case 1:
			self.jidField = tf;
			tf.keyboardType = UIKeyboardTypeEmailAddress;
			tf.text = self.jid;
			break;
		case 2:
			self.passwordField = tf;
			tf.secureTextEntry = YES;
			tf.text = self.password;
			break;
		case 3:
			self.portField = tf;
			tf.keyboardType = UIKeyboardTypeNumberPad;
			tf.text = [NSString stringWithFormat:@"%@", self.port];
			break;
	}
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"Host";
			break;
		case 1:
			return @"Your Account (JID)";
			break;
		case 2:
			return @"Password";
			break;
		case 3:
			return @"Port";
			break;
	}
	return @"";
}

#pragma mark - UITableViewDelegate

#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
	if(textField == self.hostNameField) {
		self.hostName = self.hostNameField.text;
	}
	if(textField == self.jidField) {
		self.jid = self.jidField.text;
	}
	if(textField == self.passwordField) {
		self.password = self.passwordField.text;
	}
	if (textField == self.portField) {
		self.port = [NSNumber numberWithInt:[self.portField.text integerValue]];
	}
}

#pragma mark - Interface Implementation
- (void)saveSettings
{
	Account *account = [Account new];
    account.jid = self.jid;
    account.password = self.password;
    account.hostName = self.hostName;
    account.port = self.port;
    [AccountManager storeAccount:account];
    [[MXiConnectionHandler sharedInstance] reconnectWithJID:account.jid
                                                   password:account.password
                                                   hostName:account.hostName
                                                       port:account.port
                                       authtenticationBlock:^(BOOL success) {
        // TODO: trigger reload of data in other views
        // implement some kind of notification mechanism or something
        NSLog(@"Reconnection from SettingsView successfull? %c", success);
    }];
}

#pragma mark - UINavigationBarDelegate
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
	return UIBarPositionTopAttached;
}

@end
