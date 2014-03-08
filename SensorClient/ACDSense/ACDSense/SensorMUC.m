//
// Created by Martin Weissbach on 2/25/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import "SensorMUC.h"
#import "XMPPJID.h"


@interface SensorMUC ()

@property (nonatomic, readwrite) XMPPJID *jabberID;
@property (nonatomic, readwrite) NSString *domainName;

@end

@implementation SensorMUC

- (id)initWithJabberID:(XMPPJID *)jabberID andDomainName:(NSString *)domainName
{
    if (self = [super init])
    {
        self.jabberID = jabberID;
        self.domainName = domainName;
    }

    return self;
}

@end