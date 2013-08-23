//
//  SettingsViewController.m
//  ACDSense
//
//  Created by Markus Wutzler on 23.08.13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "SettingsViewController.h"
#import "TextFieldCell.h"

@interface SettingsViewController ()
@property (retain) NSString *jid;
@property (retain) NSString *password;
@property (retain) NSString *hostName;
@property (retain) NSString *serviceJid;

@property (weak) UITextField *jidField;
@property (weak) UITextField *passwordField;
@property (weak) UITextField *hostNameField;
@property (weak) UITextField *serviceJidField;

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
	NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSDictionary *jabberSettings = [[NSDictionary dictionaryWithContentsOfFile:settingsPath] objectForKey:@"jabberInformation"];
    
    self.jid = [jabberSettings valueForKey:@"jid"];
    self.password = [jabberSettings valueForKey:@"password"];
    self.hostName = [jabberSettings valueForKey:@"hostName"];
    self.serviceJid = [jabberSettings valueForKey:@"serviceJid"];
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
			self.serviceJidField = tf;
			tf.keyboardType = UIKeyboardTypeEmailAddress;
			tf.text = self.serviceJid;
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
			return @"Service JID";
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
	if (textField == self.serviceJidField) {
		self.serviceJid = self.serviceJidField.text;
	}
}

#pragma mark - Interface Implementation
- (void)saveSettings
{
	NSString *settingsPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSDictionary *jabberSettings = @{@"jabberSettings" : @{@"jid": self.jid,
														   @"hostName": self.hostName,
														   @"serviceJid": self.serviceJid,
														   @"password": self.password}};
	
	[jabberSettings writeToFile:settingsPath atomically:YES];
}

@end
