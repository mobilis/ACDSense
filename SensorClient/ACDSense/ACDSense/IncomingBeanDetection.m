//
//  IncomingBeanDetection.m
//  ACDSense
//
//  Created by Martin Weißbach on 8/24/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "IncomingBeanDetection.h"

#import <MXi/MXiIncomingBean.h>

@implementation IncomingBeanDetection

- (NSArray *)detectBeans
{
    NSMutableArray *incomingBeans = [[NSMutableArray alloc] initWithCapacity:10];
    NSArray *classNamesAsStrings = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLoadedClasses"];
    for (NSString *classNameString in classNamesAsStrings) {
        Class actualClass = NSClassFromString(classNameString);
        if ([actualClass conformsToProtocol:@protocol(MXiIncomingBean)]) {
            id classInsance = [[actualClass alloc] init];
            [incomingBeans addObject:classInsance];
        }
    }
    return incomingBeans;
}


@end
