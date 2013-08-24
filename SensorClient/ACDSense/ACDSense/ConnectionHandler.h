//
//  ConnectionHandler.h
//  ACDSense
//
//  Created by Martin Weißbach on 8/24/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MXi/MXi.h>

@interface ConnectionHandler : NSObject <MXiBeanDelegate, MXiPresenceDelegate, MXiStanzaDelegate>

+ (instancetype)sharedInstance;

+ (instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

- (void)launchConnection;
- (void)launchConnectionWithJID:(NSString *)jabberID
                       password:(NSString *)password
                       hostName:(NSString *)hostName
                     serviceJID:(NSString *)serviceJabberID;

@end
