//
// Created by Martin Weißbach on 10/21/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import <MobilisMXi/MXi/MXiMultiUserChatRoom.h>
#import <XMPPFramework/XMPPIQ.h>
#import "MUCDiscovery.h"
#import "ACDSMultiUserChatRoom.h"
#import "MXiConnectionHandler.h"
#import "MXiMultiUserChatDiscovery.h"

@interface MUCDiscovery ()

@property (nonatomic) MXiMultiUserChatRoom *room;
@property (copy, nonatomic) void (^mucDiscoveryCompletionBlock)(BOOL, ACDSMultiUserChatRoom *);

@property (nonatomic, strong) NSString *randomRequestID;

@end

@implementation MUCDiscovery

+ (id)discoverWithRoom:(MXiMultiUserChatRoom *)room completionBlock:(void (^)(BOOL isSensorMUC, ACDSMultiUserChatRoom *acdsroom))completionBlock
{
    return [[self alloc] initWithRoom:room completionBlock:completionBlock];
}

- (id)initWithRoom:(MXiMultiUserChatRoom *)room completionBlock:(void (^)(BOOL, ACDSMultiUserChatRoom *))block
{
    self = [super init];
    if (self) {
        self.mucDiscoveryCompletionBlock = block;
        self.room = room;

        self.randomRequestID = [NSString stringWithFormat:@"%li", random()];
    }

    [self startDiscovery];
    
    return self;
}

- (void)iqStanzaReceived:(XMPPIQ *)iq
{
    if ([[iq attributeStringValueForName:@"id"] isEqualToString:self.randomRequestID]) {
        if ([self isSensorMUC:iq]) {
            ACDSMultiUserChatRoom *acdsMultiUserChatRoom = [ACDSMultiUserChatRoom roomWithMXiChatRoom:self.room andXFormElement:[[iq childElement] elementForName:@"x" xmlns:@"jabber:x:data"]];
            self.mucDiscoveryCompletionBlock(YES, acdsMultiUserChatRoom);
        } else self.mucDiscoveryCompletionBlock(NO, nil);

        [[MXiConnectionHandler sharedInstance] removeStanzaDelegate:self];
    }
}

- (BOOL)isSensorMUC:(XMPPIQ *)iq
{
    NSError *error = nil;
    NSXMLElement *formData = [[iq childElement] elementForName:@"x" xmlns:@"jabber:x:data"];
    NSArray *subjectNodes = [formData nodesForXPath:@"./field[@var='muc#roominfo_subject']" error:&error];
    if (error) {
        // TODO: error handling here for XPath Expression
        return NO;
    }

    for (NSXMLNode *node in subjectNodes)
        for (NSXMLNode *valueNode in [node children])
            if ([[valueNode stringValue] isEqualToString:@"SensorMUC"])
                return YES;

    return NO;
}


- (void)startDiscovery
{
    XMPPIQ *discoIQ = [[XMPPIQ alloc] initWithType:@"get"
                                                to:self.room.jabberID
                                         elementID:self.randomRequestID
                                             child:[NSXMLElement elementWithName:@"query" xmlns:serviceDiscoInfoNS]];
    [[MXiConnectionHandler sharedInstance] addStanzaDelegate:self];
    [[MXiConnectionHandler sharedInstance] sendElement:discoIQ];
}

@end