//
//  DLRAppStoreRatingsDataSource.h
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 2/11/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DLVersion.h"

NS_ASSUME_NONNULL_BEGIN

@interface DLRAppStoreRatingsDataSource : NSObject

@property (nullable, nonatomic) DLVersion *previousKnownVersion;
@property (nullable, nonatomic) NSDate *lastActionTakenDate;
@property (nullable, nonatomic) DLVersion *lastRatedVersion;
@property (nullable, nonatomic) DLVersion *lastDeclinedVersion;
@property (nullable, nonatomic) DLVersion *lastVersionWithFeedback;
@property (nonatomic, copy) NSDictionary <NSString *, NSNumber *> *events;

+ (instancetype)sharedInstance;
- (void)addEvent:(NSString *)eventName;
- (void)clearEvents;

@end

NS_ASSUME_NONNULL_END
