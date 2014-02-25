//
// Created by Martin Weissbach on 2/25/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPJID;


@interface SensorMUC : NSObject

@property (nonatomic, readonly) XMPPJID *jabberID;
@property (nonatomic, readonly) NSString *domainName;

- (id)initWithJabberID:(XMPPJID *)jabberID;
@end