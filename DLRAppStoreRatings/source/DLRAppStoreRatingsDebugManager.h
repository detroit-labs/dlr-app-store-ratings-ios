//
//  DLRAppStoreRatingsDebugManager.h
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 2/15/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLRAppStoreRatingsDebugManager : NSObject

+ (BOOL)shouldAlwaysShowPrompt;
+ (BOOL)shouldClearData;
+ (void)setClearData:(BOOL)newSetting;

@end
