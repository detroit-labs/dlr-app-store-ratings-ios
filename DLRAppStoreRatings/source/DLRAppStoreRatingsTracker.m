//
//  DLRAppStoreRatingsTracker.m
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 1/19/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DLRAppStoreRatingsDataSource.h"
#import "DLRAppStoreRatingsDebugManager.h"
#import "DLRAppStoreRatingsRule.h"
#import "DLRAppStoreRatingsTracker.h"
#import "UIDevice+DLR.h"

static NSString* const kAppRatingsBundleVersion = @"CFBundleShortVersionString";

@interface DLRAppStoreRatingsTracker()

@property (nonatomic) NSMutableArray *rules;
@property (nonatomic) DLRAppStoreRatingsDataSource *dataSource;

@end

@implementation DLRAppStoreRatingsTracker

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    if(self) {
        
        self.dataSource = [DLRAppStoreRatingsDataSource sharedInstance];
        
        if(![self.dataSource.previousKnownVersion isEqualToString:self.currentAppVersion]) {
            
            [self clearEvents];
            self.dataSource.previousKnownVersion = self.currentAppVersion;
        }
        
    }

    return self;
}

- (NSMutableArray *)rules {
    if(!_rules) {
        _rules = [NSMutableArray new];
    }
    return _rules;
}

- (void)addEvent:(NSString *)eventName {
    
    if ([DLRAppStoreRatingsDebugManager shouldClearData]) {
        self.dataSource.events = nil;
        self.dataSource.lastRatedVersion = nil;
        self.dataSource.lastActionTakenDate = nil;
        [DLRAppStoreRatingsDebugManager setClearData:NO];
    }
    
    if (self.paused == NO) {
        [self.dataSource addEvent:eventName];
    }
    
}

- (void)pauseEvents {
    _paused = YES;
}

- (void)unpauseEvents {
    _paused = NO;
}

- (void)addRule:(DLRAppStoreRatingsRule *)rule {
    [self.rules addObject:rule];
}

- (BOOL)shouldTriggerForScreen:(NSString *)screenName {
    
    if ([DLRAppStoreRatingsDebugManager shouldAlwaysShowPrompt]) {
        return YES;
    }
    
    if ([self.currentAppVersion isEqualToString:self.dataSource.lastRatedVersion]) {
        return NO;
    }
    
    NSDate *whenShouldWeAskAgain = [self.dataSource.lastActionTakenDate dateByAddingTimeInterval:(self.nagDays * 24 * 60 * 60)];
    if ([[NSDate date] compare:whenShouldWeAskAgain] == NSOrderedAscending) {
        return NO;
    }
    
    return [self rulesPassForScreen:screenName];
    
}

- (BOOL)rulesPassForScreen:(NSString *)screenName {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"screenName == %@",screenName];
    NSArray *filteredRules = [self.rules filteredArrayUsingPredicate:predicate];
    
    BOOL shouldTrigger = YES;
    if([filteredRules count] == 1) {
        DLRAppStoreRatingsRule *rule = [filteredRules firstObject];
        NSArray *allThresholdKeys = [rule.thresholds allKeys];
        
        if(rule.ruleBlock) {
            shouldTrigger = rule.ruleBlock();
        }
        else {
            if([allThresholdKeys count] == 0) {
                //short circuit
                return NO;
            }
        }
        
        for(NSString *key in allThresholdKeys) {
            if(self.dataSource.events[key]) {
                if([self.dataSource.events[key] integerValue] < [rule.thresholds[key] integerValue]){
                    shouldTrigger = NO;
                }
            }
            else {
                shouldTrigger = NO;
            }
        }
    }
    else {
        shouldTrigger = NO;
    }
    
    return shouldTrigger;
}

- (void)userDidSelectRateApp {
    [self clearEvents];
    [self showAppStoreReviewScreen];
    [self updateLastActionTakenDate];
    [self updateLastVersionRated];
}

- (void)showAppStoreReviewScreen {
    
    NSString *appStoreUrlFormat = @"";
    
    if ([UIDevice dlr_isSystemVersionGreaterThanOrEqualToVersion:@"8"]) {
        appStoreUrlFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";
    } else if ([UIDevice dlr_isSystemVersionGreaterThanOrEqualToVersion:@"7"]) {
        appStoreUrlFormat = @"itms-apps://itunes.apple.com/app/id%@";
    } else {
        appStoreUrlFormat = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:appStoreUrlFormat, self.appId]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)clearEvents {
    self.dataSource.events = nil;
}

- (void)userDidSelectFeedback {
    if (self.feedbackBlock) {
        self.feedbackBlock();
    }
    
    [self updateLastActionTakenDate];
}

- (void)userDidDecline {
    [self updateLastActionTakenDate];
}

- (NSString *)currentAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:kAppRatingsBundleVersion];
}

- (void)updateLastActionTakenDate {
    self.dataSource.lastActionTakenDate = [NSDate date];
}

- (void)updateLastVersionRated {
    self.dataSource.lastRatedVersion = self.currentAppVersion;
}

@end