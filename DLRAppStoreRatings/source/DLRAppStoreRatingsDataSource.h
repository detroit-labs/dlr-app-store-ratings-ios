//
//  DLRAppStoreRatingsDataSource.h
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 2/11/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DLRAppStoreRatingsDataSource : NSObject

@property (nullable, nonatomic, copy) NSString *previousKnownVersion;
@property (nullable, nonatomic, copy) NSDate *lastActionTakenDate;
@property (nullable, nonatomic, copy) NSString *lastRatedVersion;
@property (nullable, nonatomic, copy) NSString *lastDeclinedVersion;
@property (nonatomic, copy) NSDictionary <NSString *, NSNumber *> *events;

+ (instancetype)sharedInstance;
- (void)addEvent:(NSString *)eventName;
- (void)clearEvents;

@end

NS_ASSUME_NONNULL_END
