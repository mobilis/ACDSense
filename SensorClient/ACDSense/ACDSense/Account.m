//
//  Account.m
//  ACDSense
//
//  Created by Martin Weißbach on 8/24/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "Account.h"

@implementation Account

- (id)initWithJID:(NSString *)jabberID password:(NSString *)password hostName:(NSString *)hostName serviceJID:(NSString *)serviceJID
{
    self = [super init];
    if (self) {
        self.jid = jabberID;
        self.password = password;
        self.hostName = hostName;
        self.serviceJID = serviceJID;
    }
    return self;
}

@end
