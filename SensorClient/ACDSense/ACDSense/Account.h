//
//  Account.h
//  ACDSense
//
//  Created by Martin Weißbach on 8/24/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (strong, nonatomic) NSString *jid, *password, *hostName, *serviceJID;

- (id)initWithJID:(NSString *)jabberID
         password:(NSString *)password
         hostName:(NSString *)hostName
       serviceJID:(NSString *)serviceJID;

@end
