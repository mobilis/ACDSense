//
// Created by Martin Weißbach on 10/24/13.
// Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//


#import "SynchronizeRuntimeBean.h"
#import "NSXMLElement+XMPP.h"


@implementation SynchronizeRuntimeBean

- (id)initWithTargetRuntimeJID:(NSString *)jabberID
{
    self = [super initWithBeanType:SET];
    if (self) {
        self.to = [XMPPJID jidWithString:jabberID];
    }

    return self;
}

- (id)initWithServiceJIDs:(NSArray *)serviceJIDs
{
    self = [super initWithBeanType:RESULT];
    if (self) {
        self.serviceJIDs= serviceJIDs;
    }

    return self;
}


- (id)init
{
    return [self initWithBeanType:RESULT];
}

- (void)fromXML:(NSXMLElement *)xml
{
    NSArray *serviceJIDs = [xml elementsForName:@"publishNewService"];
    NSMutableArray *tempJIDs = [NSMutableArray arrayWithCapacity:serviceJIDs.count];

    for (NSXMLElement *serviceElement in serviceJIDs) {
        [tempJIDs addObject:[[serviceElement elementForName:@"serviceJID"] stringValue]];
    }

    self.serviceJIDs = [NSArray arrayWithArray:tempJIDs];
}

- (NSXMLElement *)toXML
{
    NSXMLElement *synchronizeRuntimesBean = [NSXMLElement elementWithName:@"publishNewService"
                                                                    xmlns:@"http://mobilis.inf.tu-dresden.de#XMPPBean:deployment:publishNewService"];
    for (NSString *serviceJID in self.serviceJIDs) {
        NSXMLElement *serviceJIDElement = [NSXMLElement elementWithName:@"serviceJID" stringValue:serviceJID];
        [synchronizeRuntimesBean addChild:serviceJIDElement];
    }

    return synchronizeRuntimesBean;
}

@end