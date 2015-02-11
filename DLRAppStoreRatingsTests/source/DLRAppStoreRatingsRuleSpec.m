//
//  DLRAppStoreRatingsRuleSpec.m
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 1/20/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "DLRAppStoreRatingsRule.h"

@interface DLRAppStoreRatingsRuleSpec : XCTestCase

@end

@implementation DLRAppStoreRatingsRuleSpec

DLRAppStoreRatingsRule *rule;

- (void)setUp {
    [super setUp];

    rule = [DLRAppStoreRatingsRule new];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWhenRuleIsInitialized_itHasNoThresholds {
    
    XCTAssertEqual([rule.thresholds count], 0, @"Expected thresholds to be empty");
}

-(void)testWhenSettingThresholds_itHasThresholdObjects {
    
    NSString * const eventName = @"TestEvent";
    NSNumber * const eventCount = @2;
    
    rule.thresholds = @{eventName: eventCount};
    
    XCTAssertEqual([rule.thresholds count], 1, @"Expected thresholds to have 1 entry");
}

- (void)testWhenRuleIsCreated_itHasProperValues {
    
    NSString * const screenName = @"testScreen";
    NSDictionary * const thresholdDictionary = @{@"test1" : @1};
    
    rule.screenName = screenName;
    rule.thresholds = thresholdDictionary;
    
    XCTAssertEqual(rule.screenName, screenName);
    XCTAssertEqual(rule.thresholds, thresholdDictionary);
}

@end
