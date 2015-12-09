//
//  DLRAppStoreRatingsDataSource.m
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 2/11/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import "DLRAppStoreRatingsDataSource.h"

static NSString* const kAppRatingsCurrentVersion = @"DLR_AppRatings_CurrentVersion";
static NSString* const kAppRatingsLastActionTakeDate = @"DLR_AppRatings_LastActionTaken";
static NSString* const kAppRatingsLastRatedVersion = @"DLR_AppRatings_LastRatedVersion";
static NSString* const kAppRatingsLastDeclinedVersion = @"DLR_AppRatings_LastDeclinedVersion";
static NSString* const kAppRatingsLastVersionWithFeedback = @"DLR_AppRatings_LastVersionWithFeedback";
static NSString* const kAppRatingsEvents = @"DLR_AppRatings_Events";

@implementation DLRAppStoreRatingsDataSource

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - previousKnownVersion property

- (void)setPreviousKnownVersion:(NSString *)previousKnownVersion {
    [[NSUserDefaults standardUserDefaults] setObject:previousKnownVersion forKey:kAppRatingsCurrentVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)previousKnownVersion {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAppRatingsCurrentVersion];
}

#pragma mark - lastActionTakenDate property

- (void)setLastActionTakenDate:(NSDate *)newDate {
    [[NSUserDefaults standardUserDefaults] setObject:newDate forKey:kAppRatingsLastActionTakeDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)lastActionTakenDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAppRatingsLastActionTakeDate];
}

#pragma mark - lastRatedVersion property

- (void)setLastRatedVersion:(NSString *)lastRatedVersion {
    [[NSUserDefaults standardUserDefaults] setObject:lastRatedVersion forKey:kAppRatingsLastRatedVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)lastRatedVersion {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAppRatingsLastRatedVersion];
}

#pragma mark - lastDeclinedVersion property

- (void)setLastDeclinedVersion:(NSString *)lastDeclinedVersion {
    [[NSUserDefaults standardUserDefaults] setObject:lastDeclinedVersion forKey:kAppRatingsLastDeclinedVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)lastDeclinedVersion {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAppRatingsLastDeclinedVersion];
}

#pragma mark - lastVersionWithFeedback property

- (void)setLastVersionWithFeedback:(NSString *)lastVersionWithFeedback {
    [[NSUserDefaults standardUserDefaults] setObject:lastVersionWithFeedback forKey:kAppRatingsLastVersionWithFeedback];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)lastVersionWithFeedback {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAppRatingsLastVersionWithFeedback];
}

#pragma mark - events property

- (NSDictionary *)events {
    NSDictionary *storedEvents =
    [[NSUserDefaults standardUserDefaults] objectForKey:kAppRatingsEvents];
    
    if (storedEvents == nil) {
        storedEvents = @{};
    }
    
    return storedEvents;
}

- (void)setEvents:(NSDictionary *)events {
    [[NSUserDefaults standardUserDefaults] setObject:events forKey:kAppRatingsEvents];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addEvent:(NSString *)eventName {
    NSMutableDictionary <NSString *, NSNumber *> *currentEvents = [self.events mutableCopy];
    
    if (currentEvents[eventName]) {
        currentEvents[eventName] = @([currentEvents[eventName] integerValue] + 1);
    } else {
        currentEvents[eventName] = @1;
    }
    
    self.events = currentEvents;
}

- (void)clearEvents {
    self.events = @{};
}

@end
