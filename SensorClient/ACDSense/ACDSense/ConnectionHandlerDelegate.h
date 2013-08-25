//
//  ConnectionHandlerDelegate.h
//  ACDSense
//
//  Created by Martin Weißbach on 8/24/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MXi/MXi.h>

@protocol ConnectionHandlerDelegate <NSObject>

- (void)didReceiveBean:(MXiBean<MXiIncomingBean> *)bean;

@end
