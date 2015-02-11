//
//  DLRAppStoreRatingsDataSource.h
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 2/11/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLRAppStoreRatingsDataSource : NSObject

@property (nonatomic, copy) NSString *previousKnownVersion;
@property (nonatomic, copy) NSDate *lastActionTakenDate;
@property (nonatomic, copy) NSString *lastRatedVersion;
@property (nonatomic, copy) NSMutableDictionary *events;

+ (instancetype)sharedInstance;
- (void)addEvent:(NSString *)eventName;

@end
