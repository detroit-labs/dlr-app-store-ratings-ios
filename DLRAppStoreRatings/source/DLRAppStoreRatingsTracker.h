//
//  DLRAppStoreRatingsTracker.h
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 1/19/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DLRAppStoreRatingsRule;

NS_ASSUME_NONNULL_BEGIN

@interface DLRAppStoreRatingsTracker : NSObject

@property(nonatomic, copy) NSString *appId;
@property(nullable, nonatomic, copy) void (^feedbackBlock)();
@property(nonatomic) NSInteger nagDays;
@property(nonatomic, readonly, getter=isPaused) BOOL paused;

+ (instancetype)sharedInstance;
- (void)addEvent:(NSString *)eventName;
- (void)pauseEvents;
- (void)unpauseEvents;
- (void)addRule:(DLRAppStoreRatingsRule *)rule;
- (BOOL)shouldTriggerForScreen:(NSString *)screenName;
- (void)showAppStoreReviewScreen;
- (void)userDidSelectFeedback;
- (void)userDidSelectRateApp;
- (void)userDidDecline;

@end

NS_ASSUME_NONNULL_END
