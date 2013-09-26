//
//  MainWindowController.m
//  DataGenerator
//
//  Created by Martin Weißbach on 9/25/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <MXi/MXi.h>
#import "MainWindowController.h"
#import "RoundtripInfo.h"
#import "ConnectionHandler.h"
#import "NSString+FileReading.h"
#import "MUCInfoParser.h"

@interface MainWindowController () <NSTableViewDataSource, NSTableViewDelegate, ConnectionhandlerDelegate, MXiMultiUserChatDelegate>

@property (strong) NSMutableArray *roundtripData;
@property (strong) ConnectionHandler *connectionHandler;
@property (strong) NSTimer *refreshTimer;

- (void)toggleButtons;
- (void)refreshTableView;
- (void)parseFile:(NSURL *)urlToFile;
- (void)connectToMUCs:(NSArray *)roomJIDs;

@property (weak) IBOutlet NSButton *commenceTestButton;
@property (weak) IBOutlet NSButton *finishTestButton;
@property (weak) IBOutlet NSTextField *mucRoomsTextField;
@property (weak) IBOutlet NSTableView *roundtripTableView;

- (IBAction)commenceTest:(id)sender;
- (IBAction)finishTest:(id)sender;
- (IBAction)parseMUCRooms:(id)sender;

@end

@implementation MainWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.connectionHandler = [[ConnectionHandler alloc] initWithDelegate:self andConnection:self.connection];
    self.roundtripData = [NSMutableArray arrayWithCapacity:1000];
    self.refreshTimer = [NSTimer timerWithTimeInterval:5.0
                                                target:self
                                              selector:@selector(refreshTableView)
                                              userInfo:nil
                                               repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.refreshTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.roundtripData count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RoundtripInfo *roundtripInfo = [self.roundtripData objectAtIndex:row];
    return [roundtripInfo valueForKey:tableColumn.identifier];
}

#pragma mark - Private Helper

- (void)toggleButtons
{
    [_commenceTestButton setEnabled:![_commenceTestButton isEnabled]];
    [_finishTestButton setEnabled:![_finishTestButton isEnabled]];
}

- (void)parseFile:(NSURL *)urlToFile
{
    @autoreleasepool {
        NSArray *rawMUCs = [NSString linesOfStringsOfFile:[urlToFile absoluteString]];
        NSMutableArray *mucArray = [NSMutableArray arrayWithCapacity:rawMUCs.count];
        for (NSString *rawMUC in rawMUCs)
            [mucArray addObject:[MUCInfoParser parseMUCAddressFromString:rawMUC]];

        self.connectionHandler.roomJIDs = [NSArray arrayWithArray:mucArray];
        [self connectToMUCs:mucArray];
    }
    
    [self.mucRoomsTextField setStringValue:[urlToFile absoluteString]];
    [self.commenceTestButton setEnabled:YES];
}

- (void)refreshTableView
{
    [self.roundtripTableView reloadData];
}

#pragma mark - ConnectionHandlerDelegate

- (void)sendRoundtripItem:(RoundtripInfo *)roundtripInfo
{
    @synchronized (_roundtripData) {
        [_roundtripData addObject:roundtripInfo];
    }
}

#pragma mark - MXiMultiUserChatDelegate and Helper

- (void)connectToMUCs:(NSArray *)roomJIDs
{
    for (NSString *jid in roomJIDs)
        [self.connection connectToMultiUserChatRoom:jid];
}

#pragma mark - IBAction

- (IBAction)commenceTest:(id)sender
{
    [self.connectionHandler commenceTest];

    [self toggleButtons];
}

- (IBAction)finishTest:(id)sender
{
    [self.connectionHandler finishTest];

    [self toggleButtons];
}

- (IBAction)parseMUCRooms:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:@[@"txt"]];

    if (NSFileHandlingPanelOKButton == [openPanel runModal])
        [self parseFile:[openPanel URL]];
    else return;
}

#pragma mark - Incoming Roundtrip Handler

- (void)incomingWithIdentifier:(NSUInteger)identifier andDate:(NSDate *)date
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        for (RoundtripInfo *info in self.roundtripData) {
            if ([info isSameIdentifier:identifier]) {
                [info setReceived:[date descriptionWithLocale:nil]];
                break;
            }
        }
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
//            [self refreshTableView];
//        });
    });
}

#pragma mark - MXiMultiUserChatDelegate

- (void)connectionToRoomEstablished:(NSString *)roomJID
{
    [self.commenceTestButton setEnabled:YES];
}

@end
