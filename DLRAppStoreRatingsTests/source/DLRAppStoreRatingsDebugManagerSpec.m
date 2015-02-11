//
//  DLRAppStoreRatingsDebugManagerSpec.m
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 2/15/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "DLRAppStoreRatingsDebugManager.h"

static NSString* const kAppRatingsDebugAlwaysShow = @"DLR_AppRatings_DebugAlwaysShow";
static NSString* const kAppRatingsDebugClearData = @"DLR_AppRatings_DebugClearData";

@interface DLRAppStoreRatingsDebugManagerSpec : XCTestCase

@end

@implementation DLRAppStoreRatingsDebugManagerSpec

id userDefaultsMock;

- (void)setUp {
    [super setUp];
    
    userDefaultsMock = OCMClassMock([NSUserDefaults class]);
    OCMStub([userDefaultsMock standardUserDefaults]).andReturn(userDefaultsMock);
}

- (void)tearDown {
    [super tearDown];
    
    [userDefaultsMock stopMocking];
}

- (void)test_givenStoredValueShowPromptIsSet_shouldAlwaysShowPrompt_returnsYes {
    OCMStub([userDefaultsMock boolForKey:kAppRatingsDebugAlwaysShow]).andReturn(YES);
    
    XCTAssertTrue([DLRAppStoreRatingsDebugManager shouldAlwaysShowPrompt], @"Expected shouldAlwaysShowPrompt to be true.");
}

- (void)test_givenStoredValueClearDataIsSet_shouldClearData_returnsYes {
    OCMStub([userDefaultsMock boolForKey:kAppRatingsDebugClearData]).andReturn(YES);
    
    XCTAssertTrue([DLRAppStoreRatingsDebugManager shouldClearData], @"Expected shouldClearData to be true.");
}

- (void)test_givenNewSettingIsNo_whenSettingClearData_setsClearDataToNo {
    
    [DLRAppStoreRatingsDebugManager setClearData:NO];
    
    OCMVerify([userDefaultsMock setBool:NO forKey:kAppRatingsDebugClearData]);
}

@end
