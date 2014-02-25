//
// Created by Martin Weissbach on 2/25/14.
// Copyright (c) 2014 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SensorMUCValidator : NSObject

+ (void)launchValidationWithConnection:(MXiAbstractConnectionHandler *)connectionHandler jid:(NSString *)roomJID completionBlock:(void (^)(BOOL, NSString *))completionBlock;

- (id)initWithConnection:(MXiAbstractConnectionHandler *)handler jid:(NSString *)jid completionBlock:(void (^)(BOOL, NSString *))completionBlock;
@end