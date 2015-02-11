//
//  DLRAppStoreRatingsDebugManager.m
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 2/15/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import "DLRAppStoreRatingsDebugManager.h"

static NSString* const kAppRatingsDebugAlwaysShow = @"DLR_AppRatings_DebugAlwaysShow";
static NSString* const kAppRatingsDebugClearData = @"DLR_AppRatings_DebugClearData";

@implementation DLRAppStoreRatingsDebugManager

+ (BOOL)shouldAlwaysShowPrompt {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAppRatingsDebugAlwaysShow];
}

+ (BOOL)shouldClearData {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAppRatingsDebugClearData];
}

+ (void)setClearData:(BOOL)newSetting {
    [[NSUserDefaults standardUserDefaults] setBool:newSetting forKey:kAppRatingsDebugClearData];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
