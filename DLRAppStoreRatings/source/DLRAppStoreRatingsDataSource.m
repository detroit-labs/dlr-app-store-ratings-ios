//
//  DLRAppStoreRatingsDataSource.m
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 2/11/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import "DLRAppStoreRatingsDataSource.h"

#import "DLVersion.h"

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

- (void)setPreviousKnownVersion:(DLVersion *)previousKnownVersion {
    [[NSUserDefaults standardUserDefaults] setObject:previousKnownVersion.string forKey:kAppRatingsCurrentVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (DLVersion *)previousKnownVersion {
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppRatingsCurrentVersion];
    
    if (version != nil) {
        return [DLVersion versionWithString:version];
    }
    else {
        return nil;
    }
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

- (void)setLastRatedVersion:(DLVersion *)lastRatedVersion {
    [[NSUserDefaults standardUserDefaults] setObject:lastRatedVersion.string forKey:kAppRatingsLastRatedVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (DLVersion *)lastRatedVersion {
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppRatingsLastRatedVersion];
    
    if (version != nil) {
        return [DLVersion versionWithString:version];
    }
    else {
        return nil;
    }
}

#pragma mark - lastDeclinedVersion property

- (void)setLastDeclinedVersion:(DLVersion *)lastDeclinedVersion {
    [[NSUserDefaults standardUserDefaults] setObject:lastDeclinedVersion.string forKey:kAppRatingsLastDeclinedVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (DLVersion *)lastDeclinedVersion {
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppRatingsLastDeclinedVersion];
    
    if (version != nil) {
        return [DLVersion versionWithString:version];
    }
    else {
        return nil;
    }
}

#pragma mark - lastVersionWithFeedback property

- (void)setLastVersionWithFeedback:(DLVersion *)lastVersionWithFeedback {
    [[NSUserDefaults standardUserDefaults] setObject:lastVersionWithFeedback.string forKey:kAppRatingsLastVersionWithFeedback];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (DLVersion *)lastVersionWithFeedback {
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:kAppRatingsLastVersionWithFeedback];
    
    if (version != nil) {
        return [DLVersion versionWithString:version];
    }
    else {
        return nil;
    }
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
