//
//  Timestamp+Description.h
//  ACDSense
//
//  Created by Martin Weißbach on 9/3/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import "Timestamp.h"

@interface Timestamp (Description)

- (NSString *)timestampAsString;
- (NSDate *)timestampAsDate;

@end
