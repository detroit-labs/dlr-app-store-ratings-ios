//
//  DLRAppStoreRatingsTrackerSpec.m
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 1/19/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>

#import "DLRAppStoreRatingsDataSource.h"
#import "DLRAppStoreRatingsDebugManager.h"
#import "DLRAppStoreRatingsTracker.h"
#import "DLRAppStoreRatingsRule.h"

static NSString* const kAppRatingsBundleVersion = @"CFBundleShortVersionString";

id dataSourceMock;

@interface DLRAppStoreRatingsTracker (Test)

@property (nonatomic) NSMutableArray *rules;
@property (nonatomic) DLRAppStoreRatingsDataSource *dataSource;

@end

@implementation DLRAppStoreRatingsTracker (Test)

@dynamic rules;
@dynamic dataSource;

// need to override the dataSource with the mock
- (DLRAppStoreRatingsDataSource*)dataSource {
    return dataSourceMock;
}

@end

@interface DLRAppStoreRatingsTrackerSpec : XCTestCase

@end

@implementation DLRAppStoreRatingsTrackerSpec

id bundleMock;
id deviceMock;
id debugManagerMock;
id sharedApplication;

DLRAppStoreRatingsTracker *tracker;
NSString *version;


- (void)setUp {
    [super setUp];
    
    version = @"3.1.1";
    
    bundleMock = OCMClassMock([NSBundle class]);
    NSDictionary *infoDictionary = @{kAppRatingsBundleVersion: version};
    OCMStub([bundleMock infoDictionary]).andReturn(infoDictionary);
    OCMStub(ClassMethod([bundleMock mainBundle])).andReturn(bundleMock);
    
    sharedApplication = OCMClassMock([UIApplication class]);
    OCMStub([sharedApplication sharedApplication]).andReturn(sharedApplication);
    
    deviceMock = OCMClassMock([UIDevice class]);
    OCMStub(ClassMethod([deviceMock currentDevice])).andReturn(deviceMock);
    
    dataSourceMock = OCMClassMock([DLRAppStoreRatingsDataSource class]);
    OCMStub(ClassMethod([dataSourceMock sharedInstance])).andReturn(dataSourceMock);
    
    debugManagerMock = OCMClassMock([DLRAppStoreRatingsDebugManager class]);
    
    tracker = [DLRAppStoreRatingsTracker new];
    tracker.appId = @"12345";
    tracker.dataSource = dataSourceMock;
}

- (void)tearDown {
    [super tearDown];
    
    [bundleMock stopMocking];
    [sharedApplication stopMocking];
    [deviceMock stopMocking];
    [dataSourceMock stopMocking];
    [debugManagerMock stopMocking];
}

-(void)test_whenGettingSharedInstance_itReturnsAnExistingInstance {
    DLRAppStoreRatingsTracker* firstTracker = [DLRAppStoreRatingsTracker sharedInstance];
    DLRAppStoreRatingsTracker* secondTracker = [DLRAppStoreRatingsTracker sharedInstance];
    
    XCTAssertEqual(firstTracker, secondTracker, @"Expected both trackers to be the same object.");
}

-(void)test_whenAddingAnEvent_itAddsEventsToTheDataSource {
    
    NSMutableDictionary *initialEvents = [NSMutableDictionary dictionaryWithDictionary:@{}];
    
    OCMStub([dataSourceMock events]).andReturn(initialEvents);
    
    NSString * const eventName = @"TestEvent";
    
    [tracker addEvent:eventName];
    
    OCMVerify([dataSourceMock addEvent:eventName]);
}

-(void)test_givenEventsArePaused_whenAddingAnEvent_itDoesNotAddEvent {
    
    NSString * const eventName = @"TestEvent";
    
    [tracker pauseEvents];
    
    // addEvent should never be called
    [[dataSourceMock reject] addEvent:eventName];
    
    [tracker addEvent:eventName];
    
}

-(void)test_givenEventsAreUnpaused_whenAddingAnEvent_itAddsTheEvent {
    
    NSString * const eventName = @"TestEvent";
    
    // create strict mock and addEvent should only be called once
    dataSourceMock = OCMStrictClassMock([DLRAppStoreRatingsDataSource class]);
    [[dataSourceMock expect] addEvent:eventName];
    
    tracker.dataSource = dataSourceMock;
    
    [tracker pauseEvents];
    
    [tracker addEvent:eventName];
    
    [tracker unpauseEvents];
    
    [tracker addEvent:eventName];
    
}

- (void)test_whenTrackerIsInitialized_itHasNoRules {
    
    XCTAssertEqual([tracker.rules count], 0, @"Expected rules to be empty");
}

- (void)test_whenRuleIsAddedToTracker_itHasOneRule {
    
    [tracker addRule:[DLRAppStoreRatingsRule new]];
    
    XCTAssertEqual([tracker.rules count], 1, @"Expected rules to have 1 entry");
    
}

- (void)test_givenThereIsOneEvent_andEventCountEqualsRulesThreshold_shouldTrigger_returnsTrue {

    NSString * const eventName = @"TestEvent";
    NSNumber * const eventCount = @1;
    NSDictionary *events = @{eventName: eventCount};

    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule new];
    rule.thresholds = @{eventName: eventCount};
    rule.screenName = @"screenName";
    [tracker.rules addObject:rule];
    
    OCMStub([dataSourceMock events]).andReturn(events);

    XCTAssertTrue([tracker shouldTriggerForScreen:@"screenName"], @"Expected shouldTrigger to be TRUE");

}

- (void)test_givenThereIsOneEvent_andEventIsLessThanTheThreshold_shouldTrigger_returnsFalse {

    NSString * const eventName = @"TestEvent";
    NSDictionary *events = @{eventName: @1};
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule new];
    rule.thresholds = @{eventName: @2};
    rule.screenName = @"screenName";
    [tracker.rules addObject:rule];
    
    OCMStub([dataSourceMock events]).andReturn(events);
    
    XCTAssertFalse([tracker shouldTriggerForScreen:@"screenName"], @"Expected shouldTrigger to be FALSE");

}

- (void)test_givenThereIsARuleBlock_andItEvaluatesToTrue_shouldTrigger_returnsTrue {
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.screenName = @"Test Screen";
    [tracker addRule:rule];
    
    XCTAssertTrue([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be TRUE");
    
}

- (void)test_givenThereIsNoRuleBlock_andNoTriggers_shouldTrigger_returnsFalse {
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule new];
    
    rule.screenName = @"Test Screen";
    [tracker addRule:rule];
    
    
    XCTAssertFalse([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be FALSE");
}

- (void)test_givenThereIsRuleBlock_andTriggersAreBothTrue_shouldTrigger_returnsTrue {
    NSString * const eventName = @"TestEvent";
    NSNumber * const eventCount = @1;
    NSDictionary *events = @{eventName: eventCount};
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.thresholds = @{eventName: eventCount};
    rule.screenName = @"screenName";
    [tracker.rules addObject:rule];
    
    OCMStub([dataSourceMock events]).andReturn(events);
    
    XCTAssertTrue([tracker shouldTriggerForScreen:@"screenName"], @"Expected shouldTrigger to be TRUE");
}

- (void)test_givenRuleBlockIsTrue_andTriggersAreFalse_shouldTrigger_returnsFalse {
    NSString * const eventName = @"TestEvent";
    NSNumber * const eventCount = @2;
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.thresholds = @{eventName: eventCount};
    rule.screenName = @"screenName";
    [tracker.rules addObject:rule];
    
    [tracker addEvent:eventName];
    
    XCTAssertFalse([tracker shouldTriggerForScreen:@"screenName"], @"Expected shouldTrigger to be False");
}

- (void)test_givenRuleBlockIsFalse_andTriggersAreTrue_shouldTrigger_returnsFalse {
    NSString * const eventName = @"TestEvent";
    NSNumber * const eventCount = @1;
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return NO;
    }];
    rule.thresholds = @{eventName: eventCount};
    rule.screenName = @"screenName";
    [tracker.rules addObject:rule];
    
    [tracker addEvent:eventName];
    
    XCTAssertFalse([tracker shouldTriggerForScreen:@"screenName"], @"Expected shouldTrigger to be False");
}

- (void)test_givenRuleBlockAndTriggersAreBothFalse_shouldTrigger_returnsFalse {
    NSString * const eventName = @"TestEvent";
    NSNumber * const eventCount = @2;
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return NO;
    }];
    rule.thresholds = @{eventName: eventCount};
    rule.screenName = @"screenName";
    [tracker.rules addObject:rule];
    
    [tracker addEvent:eventName];
    
    XCTAssertFalse([tracker shouldTriggerForScreen:@"screenName"], @"Expected shouldTrigger to be False");
}

- (void)test_givenAppVersionHasAlreadyBeenReviewed_shouldTrigger_returnsFalse {

    OCMStub([dataSourceMock lastRatedVersion]).andReturn(version);
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.screenName = @"Test Screen";

    [tracker addRule:rule];
    
    XCTAssertFalse([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be FALSE");
}

- (void)test_givenAppVersionHasAlreadyBeenDeclined_andShouldPromptForDeclinedVersionsIsTrue_shouldTrigger_returnsTrue {
    
    OCMStub([dataSourceMock lastDeclinedVersion]).andReturn(version);
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.screenName = @"Test Screen";
    
    [tracker addRule:rule];
    
    XCTAssertTrue([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be TRUE");
}

- (void)test_givenAppVersionHasAlreadyBeenDeclined_andShouldPromptForDeclinedVersionsIsFalse_shouldTrigger_returnsFalse {
    
    OCMStub([dataSourceMock lastDeclinedVersion]).andReturn(version);
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.screenName = @"Test Screen";
    
    tracker.shouldPromptForDeclinedVersions = NO;
    [tracker addRule:rule];
    
    XCTAssertFalse([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be FALSE");
}

- (void)test_givenAppVersionHasAlreadyBeenGivenFeedback_andShouldPromptForVersionsWithFeedbackIsTrue_shouldTrigger_returnsTrue {
    
    OCMStub([dataSourceMock lastVersionWithFeedback]).andReturn(version);
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.screenName = @"Test Screen";
    
    [tracker addRule:rule];
    
    XCTAssertTrue([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be TRUE");
}

- (void)test_givenAppVersionHasAlreadyBeenGivenFeedback_andShouldPromptForVersionsWithFeedbackIsIsFalse_shouldTrigger_returnsFalse {
    
    OCMStub([dataSourceMock lastVersionWithFeedback]).andReturn(version);
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.screenName = @"Test Screen";
    
    tracker.shouldPromptForVersionsWithFeedback = NO;
    [tracker addRule:rule];
    
    XCTAssertFalse([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be FALSE");
}

- (void)test_givenAppVersionHasNotAlreadyBeenReviewed_shouldTrigger_returnsTrue {
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.screenName = @"Test Screen";
    tracker.dataSource.lastRatedVersion = @"3.0.0";
    [tracker addRule:rule];
    
    XCTAssertTrue([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be TRUE");
}

- (void)test_giveniOS6_whenShowingAppStoreReviewScreen_itOpensiTunesReviewScreenForApp {

    OCMStub([(UIDevice*)deviceMock systemVersion]).andReturn(@"6.0");
    
    [tracker showAppStoreReviewScreen];
    NSURL * url = [NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=12345"];
    OCMVerify([sharedApplication openURL:url]);
    
}

- (void)test_giveniOS70_whenShowingAppStoreReviewScreen_itOpensiTunesReviewScreenForApp {
    
    OCMStub([(UIDevice*)deviceMock systemVersion]).andReturn(@"7.0");
    
    [tracker showAppStoreReviewScreen];
    NSURL * url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id12345"];
    OCMVerify([sharedApplication openURL:url]);
    
}

- (void)test_giveniOS71_whenShowingAppStoreReviewScreen_itOpensiTunesReviewScreenForApp {
    
    OCMStub([(UIDevice*)deviceMock systemVersion]).andReturn(@"7.1");
    
    [tracker showAppStoreReviewScreen];
    NSURL * url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id12345"];
    OCMVerify([sharedApplication openURL:url]);
    
}

- (void)test_giveniOS8_whenShowingAppStoreReviewScreen_itOpensiTunesReviewScreenForApp {
    
    OCMStub([(UIDevice*)deviceMock systemVersion]).andReturn(@"8.0");
    
    [tracker showAppStoreReviewScreen];
    NSURL * url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=12345&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"];
    OCMVerify([sharedApplication openURL:url]);
    
}

- (void)test_giveniOS81_whenShowingAppStoreReviewScreen_itOpensiTunesReviewScreenForApp {
    
    OCMStub([(UIDevice*)deviceMock systemVersion]).andReturn(@"8.1");
    
    [tracker showAppStoreReviewScreen];
    NSURL * url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=12345&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"];
    OCMVerify([sharedApplication openURL:url]);
    
}

- (void)test_whenRatingApp_itClearsTheEventsFromTracker {
    [tracker addEvent:@"Test Event"];
    
    [tracker userDidSelectRateApp];
    
    XCTAssertEqual([tracker.dataSource.events count], 0, @"Expected events to be cleared out.");
}

- (void)test_whenRatingApp_itClearsEventsFromStorage {
    
    [tracker userDidSelectRateApp];
    
    OCMVerify([dataSourceMock clearEvents]);
}

- (void)test_whenUserSelectsFeedbackOption_executesFeedbackBlock {
    
    __block BOOL feedbackBool = NO;
    tracker.feedbackBlock = ^{
        feedbackBool = YES;
    };
    
    [tracker userDidSelectFeedback];
    
    XCTAssertTrue(feedbackBool, @"Expected feedbackBool to be TRUE");
}

- (void)test_givenAppVersionIsUpdated_whenTrackerIsInitialized_itClearsEvents {
    
    // already have a tracker at version 3.1.1
    
    // stub out bundle so that the new version is higher than the old version
    
    NSDictionary *infoDictionary = @{kAppRatingsBundleVersion: @"4.0.0"};
    OCMStub([bundleMock infoDictionary]).andReturn(infoDictionary);
    OCMStub(ClassMethod([bundleMock mainBundle])).andReturn(bundleMock);
    
    OCMStub([dataSourceMock previousKnownVersion]).andReturn(@"3.0.0");
    
    tracker = [DLRAppStoreRatingsTracker new];
    
    OCMVerify([dataSourceMock clearEvents]);
    
}

- (void)test_givenAppVersionIsUpdated_whenTrackerIsInitialized_itTellsDataSourceToStoreUpdatedAppVersion {
    
    // already have a tracker at version 3.1.1
    
    // stub out bundle so that the new version is higher than the old version
    // recreate bundle mock so we can stub out the same key with a different value
    bundleMock = OCMClassMock([NSBundle class]);
    NSDictionary *infoDictionary = @{kAppRatingsBundleVersion: @"4.0.0"};
    OCMStub([bundleMock infoDictionary]).andReturn(infoDictionary);
    OCMStub(ClassMethod([bundleMock mainBundle])).andReturn(bundleMock);
    
    OCMStub([dataSourceMock previousKnownVersion]).andReturn(@"3.0.0");
    
    tracker = [DLRAppStoreRatingsTracker new];
    
    OCMVerify([dataSourceMock setPreviousKnownVersion:@"4.0.0"]);
    
}

- (void)test_whenUserSaysNoToRatingOrFeedback_itSetsTheLastActionTakenDateToToday {
    
    NSDate* now = [NSDate date];
    
    id dateMock = OCMClassMock([NSDate class]);
    OCMStub(ClassMethod([dateMock date])).andReturn(now);
    
    [tracker userDidDecline];
    
    OCMVerify([dataSourceMock setLastActionTakenDate:now]);
    
    [dateMock stopMocking];
}

- (void)test_whenUserSaysNoToRatingOrFeedback_itSetsTheLastDeclinedVersionOfTheApp {
    // already have a tracker at version 3.1.1
    
    // stub out bundle so that the new version is higher than the old version
    // recreate bundle mock so we can stub out the same key with a different value
    bundleMock = OCMClassMock([NSBundle class]);
    NSDictionary *infoDictionary = @{kAppRatingsBundleVersion: @"4.0.0"};
    OCMStub([bundleMock infoDictionary]).andReturn(infoDictionary);
    OCMStub(ClassMethod([bundleMock mainBundle])).andReturn(bundleMock);
    
    [tracker userDidDecline];
    
    OCMVerify([dataSourceMock setLastDeclinedVersion:@"4.0.0"]);
}

- (void)test_whenUserGivesFeedback_itSetsTheLastActionTakenDateToToday {
    
    NSDate* now = [NSDate date];
    
    id dateMock = OCMClassMock([NSDate class]);
    OCMStub(ClassMethod([dateMock date])).andReturn(now);
    
    [tracker userDidSelectFeedback];
    
    OCMVerify([dataSourceMock setLastActionTakenDate:now]);
    
    [dateMock stopMocking];
}

- (void)test_whenUserGivesFeedback_itSetsTheLastVersionWithFeedbackOfTheApp {
    // already have a tracker at version 3.1.1
    
    // stub out bundle so that the new version is higher than the old version
    // recreate bundle mock so we can stub out the same key with a different value
    bundleMock = OCMClassMock([NSBundle class]);
    NSDictionary *infoDictionary = @{kAppRatingsBundleVersion: @"4.0.0"};
    OCMStub([bundleMock infoDictionary]).andReturn(infoDictionary);
    OCMStub(ClassMethod([bundleMock mainBundle])).andReturn(bundleMock);
    
    [tracker userDidSelectFeedback];
    
    OCMVerify([dataSourceMock setLastVersionWithFeedback:@"4.0.0"]);
}

- (void)test_whenUserRatesApp_itSetsTheLastActionTakenDateToToday {
    
    NSDate* now = [NSDate date];
    
    id dateMock = OCMClassMock([NSDate class]);
    OCMStub(ClassMethod([dateMock date])).andReturn(now);
    
    [tracker userDidSelectRateApp];
    
    OCMVerify([dataSourceMock setLastActionTakenDate:now]);
    
    [dateMock stopMocking];
}

- (void)test_whenUserRatesApp_itSetsTheLastRatedVersionOfTheApp {
    
    // already have a tracker at version 3.1.1
    
    // stub out bundle so that the new version is higher than the old version
    // recreate bundle mock so we can stub out the same key with a different value
    bundleMock = OCMClassMock([NSBundle class]);
    NSDictionary *infoDictionary = @{kAppRatingsBundleVersion: @"4.0.0"};
    OCMStub([bundleMock infoDictionary]).andReturn(infoDictionary);
    OCMStub(ClassMethod([bundleMock mainBundle])).andReturn(bundleMock);
    
    [tracker userDidSelectRateApp];
    
    OCMVerify([dataSourceMock setLastRatedVersion:@"4.0.0"]);
    
}

- (void)test_givenRulesPass_andNagTimerHasNotBeenReached_shouldTrigger_returnsFalse {
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.screenName = @"Test Screen";
    [tracker addRule:rule];
    
    NSDate *now = [NSDate date];
    OCMStub([dataSourceMock lastActionTakenDate]).andReturn(now);
    tracker.nagDays = 1;
    
    [tracker userDidDecline];
    
    XCTAssertFalse([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be FALSE");
}

- (void)test_givenRulesPass_andNagTimerHasBeenReached_shouldTrigger_returnsTrue {
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return YES;
    }];
    rule.screenName = @"Test Screen";
    [tracker addRule:rule];
    
    tracker.nagDays = -1;
    
    [tracker userDidDecline];
    
    XCTAssertTrue([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be TRUE");
}

- (void)test_givenDebugSettingForAlwaysShowSetOn_shouldTrigger_returnsTrue {
    
    DLRAppStoreRatingsRule *rule = [DLRAppStoreRatingsRule ruleWithBlock:^{
        return NO;
    }];
    rule.screenName = @"Test Screen";
    [tracker addRule:rule];
    
    tracker.nagDays = 1;
    
    OCMStub([debugManagerMock shouldAlwaysShowPrompt]).andReturn(YES);
    
    XCTAssertTrue([tracker shouldTriggerForScreen:@"Test Screen"], @"Expected shouldTrigger to be TRUE");
}

- (void)test_givenDebugSettingForClearDataOn_whenNextEventIsAdded_itClearsEvents {
    NSString * const eventName = @"TestEvent";
    
    OCMStub([debugManagerMock shouldClearData]).andReturn(YES);
    
    [tracker addEvent:eventName];
    
    OCMVerify([dataSourceMock clearEvents]);
    
}

- (void)test_givenDebugSettingForClearDataOn_whenNextEventIsAdded_itClearsLastRatedVersion {
    NSString * const eventName = @"TestEvent";
    
    OCMStub([debugManagerMock shouldClearData]).andReturn(YES);
    
    tracker.dataSource.lastRatedVersion = @"4.0.0";
    
    [tracker addEvent:eventName];
    
    OCMVerify([tracker.dataSource setLastRatedVersion:nil]);
    
}

- (void)test_givenDebugSettingForClearDataOn_whenNextEventIsAdded_itClearsLastActionTakenDate {
    NSString * const eventName = @"TestEvent";
    
    OCMStub([debugManagerMock shouldClearData]).andReturn(YES);
    
    tracker.dataSource.lastActionTakenDate = [NSDate date];
    
    [tracker addEvent:eventName];
    
    XCTAssertNil(tracker.dataSource.lastActionTakenDate);
    
}

- (void)test_givenDebugSettingForClearDataOn_whenNextEventIsAdded_itSetsDebugFlagBackToNo {
    NSString * const eventName = @"TestEvent";
    
    OCMStub([debugManagerMock shouldClearData]).andReturn(YES);
    
    [tracker addEvent:eventName];
    
    OCMVerify([debugManagerMock setClearData:NO]);
    
}


@end

