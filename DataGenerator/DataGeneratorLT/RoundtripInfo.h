//
//  RoundtripInfo.h
//  ACDSenseWorkspace
//
//  Created by Martin Weißbach on 9/25/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//



@interface RoundtripInfo : NSObject

@property (strong) NSString *sent;
@property (strong) NSString *received;
@property (strong, readonly) NSString *roundtrip;

@property NSUInteger roundtripIdentifier;

- (id)initWithStartDate:(NSDate *)startDate andIdentifier:(NSUInteger)roundtripIdentifier;

- (BOOL)isSameIdentifier:(NSUInteger)otherIdentifier;

@end
