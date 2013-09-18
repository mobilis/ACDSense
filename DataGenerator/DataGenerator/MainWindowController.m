//
//  MainWindowController.m
//  DataGenerator
//
//  Created by Martin Weißbach on 9/17/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "MainWindowController.h"
#import "AppDelegate.h"

@interface MainWindowController () <NSTextFieldDelegate>

@property (strong, nonatomic) NSString *mucFile;
@property (strong, nonatomic) NSString *weatherDataDirectory;

@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSTextField *mucFileTextField;
@property (weak) IBOutlet NSTextField *weatherDirectoryTextField;

- (IBAction)chooseMUCFile:(id)sender;
- (IBAction)chooseWeatherDirectory:(id)sender;
- (IBAction)startSetup:(id)sender;

@end

@implementation MainWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
}

#pragma mark - IBAction

- (IBAction)chooseMUCFile:(id)sender {
    NSOpenPanel *fileChooserPanel = [self chooserPanelWithFiles:YES directories:NO];

    NSInteger buttonClicked = [fileChooserPanel runModal];
    if (buttonClicked == NSFileHandlingPanelCancelButton) {
        return;
    }

    NSArray *choosenMUCFiles = [fileChooserPanel URLs];
    self.mucFile = ((NSURL *)choosenMUCFiles[0]).absoluteString;

    [self.mucFileTextField setStringValue:_mucFile];
    [self updateStartButton];
}

- (IBAction)chooseWeatherDirectory:(id)sender {
    NSOpenPanel *directoryChooserPanel = [self chooserPanelWithFiles:NO directories:YES];

    NSInteger buttonClicked = [directoryChooserPanel runModal];
    if (buttonClicked == NSFileHandlingPanelCancelButton) {
        return;
    }

    NSArray *choosenDirectories = [directoryChooserPanel URLs];
    self.weatherDataDirectory = ((NSURL *)choosenDirectories[0]).absoluteString;

    [self.weatherDirectoryTextField setStringValue:_weatherDataDirectory];
    [self updateStartButton];
}

- (IBAction)startSetup:(id)sender {
    if ([self.delegate respondsToSelector:@selector(getMUCInformationFromFile:)]) {
        [self.delegate performSelector:@selector(getMUCInformationFromFile:) withObject:_mucFile];
    }
    if ([self.delegate respondsToSelector:@selector(launchDataLoadingFromDirectory:)]) {
        [self.delegate performSelector:@selector(launchDataLoadingFromDirectory:) withObject:_weatherDataDirectory];
    }
    if ([self.delegate respondsToSelector:@selector(launchConnectionEstablishment)]) {
        [self.delegate performSelector:@selector(launchConnectionEstablishment)];
    }
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj
{
    self.mucFile = _mucFileTextField.stringValue;
    self.weatherDataDirectory = _weatherDirectoryTextField.stringValue;
    [self updateStartButton];
}

#pragma mark - IBAction Helper

- (NSOpenPanel *)chooserPanelWithFiles:(BOOL)allowFiles directories:(BOOL)allowDirectories
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:allowDirectories];
    [openPanel setCanChooseFiles:allowFiles];
    [openPanel setAllowsMultipleSelection:NO];

    if (allowFiles)
        [openPanel setAllowedFileTypes:@[@"txt"]];

    return openPanel;
}

- (void)updateStartButton
{
    if (_weatherDataDirectory && _mucFile && _weatherDataDirectory.length > 0 && _mucFile.length > 0)
        [_startButton setEnabled:YES];
    else [_startButton setEnabled:NO];
}
@end
