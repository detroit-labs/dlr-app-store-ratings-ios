//
//  DLRAppStoreRatingsRule.h
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 1/20/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLRAppStoreRatingsRule : NSObject

@property (nonatomic, copy) NSString *screenName;
@property (nonatomic, copy) NSDictionary *thresholds;
@property (nonatomic, copy) BOOL (^ruleBlock)(void);

+ (DLRAppStoreRatingsRule *)ruleWithBlock:(BOOL (^)(void))ruleBlock;

@end
