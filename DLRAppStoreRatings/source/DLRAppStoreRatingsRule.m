//
//  DLRAppStoreRatingsRule.m
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 1/20/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import "DLRAppStoreRatingsRule.h"

@implementation DLRAppStoreRatingsRule

+ (DLRAppStoreRatingsRule *)ruleWithBlock:(BOOL (^)(void))ruleBlock {
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule new];
    rule.ruleBlock = ruleBlock;
    return rule;
}

@end
