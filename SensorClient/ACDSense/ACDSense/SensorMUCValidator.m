//
// Created by Martin Weissbach on 2/25/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <MobilisMXi/MXi/MXiConnection.h>
#import "SensorMUCValidator.h"

@implementation SensorMUCValidator
{
    __strong MXiAbstractConnectionHandler *_connectionHandler;
    __strong NSString *_jid;
    __strong void (^_completionBlock)(BOOL, NSString *);
}

+ (void)launchValidationWithConnection:(MXiAbstractConnectionHandler *)connectionHandler jid:(NSString *)roomJID completionBlock:(void (^)(BOOL, NSString *))completionBlock
{
    [[self alloc] initWithConnection:connectionHandler jid:roomJID completionBlock:completionBlock];
}

- (id)initWithConnection:(MXiAbstractConnectionHandler *)handler jid:(NSString *)jid completionBlock:(void (^)(BOOL, NSString *))completionBlock
{
    if (self = [super init])
    {
        _connectionHandler = handler;
        _jid = jid;
        _completionBlock = completionBlock;

        [_connectionHandler.connection addStanzaDelegate:self withSelector:@selector(iqStanzaReceived:) forStanzaElement:IQ];
        [self launchDiscovery];
    }

    return self;
}

- (void)launchDiscovery
{
    XMPPIQ *infoIQ = [XMPPIQ iqWithType:@"get" to:[XMPPJID jidWithString:_jid] elementID:@"roomInfo" child:[NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"]];
    [_connectionHandler sendElement:infoIQ];
}

- (void)iqStanzaReceived:(XMPPIQ *)iq
{
    NSError *error = nil;
    NSArray *fieldNodes = [[[iq elementForName:@"query"] elementForName:@"x"] elementsForName:@"field"];
    if (!fieldNodes || fieldNodes.count == 0)
    {
        _completionBlock(NO, nil);
    }
    else
    {
        for (NSXMLElement *fieldNode in fieldNodes)
        {
            if (    [[fieldNode attributeStringValueForName:@"var"] isEqualToString:@"muc#roominfo_subject"] &&
                    [[fieldNode stringValue] isEqualToString:@"SensorMUC"]
                    )
            {
                for (NSXMLElement *node in fieldNodes)
                {
                    if ([[node attributeStringValueForName:@"var"] isEqualToString:@"muc#roominfo_description"])
                    {
                        _completionBlock(YES, [node stringValue]);
                    }
                }
                _completionBlock(YES, nil);
            }
        }
    }
}

@end