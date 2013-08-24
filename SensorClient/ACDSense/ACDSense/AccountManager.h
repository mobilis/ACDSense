//
//  AccountManager.h
//  ACDSense
//
//  Created by Martin Weißbach on 8/24/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Account.h"

@interface AccountManager : NSObject

+ (void)storeAccount:(Account *)account;
+ (Account *)account;

@end
