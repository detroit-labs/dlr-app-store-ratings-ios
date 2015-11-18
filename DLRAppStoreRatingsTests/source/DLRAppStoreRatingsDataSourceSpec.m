//
//  DLRAppStoreRatingsDataSourceSpec.m
//  DLRAppStoreRatings
//
//  Created by Christopher Trevarthen on 2/11/15.
//  Copyright (c) 2015 Detroit Labs, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>

#import "DLRAppStoreRatingsDataSource.h"

static NSString* const kAppRatingsEvents = @"DLR_AppRatings_Events";
static NSString* const kAppRatingsLastActionTakeDate = @"DLR_AppRatings_LastActionTaken";
static NSString* const kAppRatingsLastRatedVersion = @"DLR_AppRatings_LastRatedVersion";

@interface DLRAppStoreRatingsDataSourceSpec : XCTestCase

@end


@implementation DLRAppStoreRatingsDataSourceSpec

DLRAppStoreRatingsDataSource *dataSource;
id userDefaultsMock;
id dateMock;
NSDate *now;

- (void)setUp {
    [super setUp];
    
    // stub NSUserDefaults
    userDefaultsMock = OCMClassMock([NSUserDefaults class]);
    OCMStub([userDefaultsMock standardUserDefaults]).andReturn(userDefaultsMock);
    
    now = [NSDate date];
    dateMock = OCMClassMock([NSDate class]);
    OCMStub(ClassMethod([dateMock date])).andReturn(now);
    
    dataSource = [DLRAppStoreRatingsDataSource new];
}

- (void)tearDown {
    [super tearDown];
    
    [dateMock stopMocking];
}

- (void)test_lastActionDate_getsTheLastActionDateFromStorage {
    
    OCMStub([userDefaultsMock objectForKey:kAppRatingsLastActionTakeDate]).andReturn(now);
    
    XCTAssertEqual(dataSource.lastActionTakenDate, now, @"Expected lastActionDate to be equal to now");
    
}

- (void)test_whenUpdatingLastActionDate_itStoresTheLastActionDate {

    dataSource.lastActionTakenDate = now;

    OCMVerify([userDefaultsMock setObject:now forKey:kAppRatingsLastActionTakeDate]);

}

- (void)test_lastRatedVersion_getsTheLastVersionRatedFromStorage {
    
    NSString *version = @"3.0.0";
    
    OCMStub([userDefaultsMock objectForKey:kAppRatingsLastRatedVersion]).andReturn(version);
    
    XCTAssertEqual(dataSource.lastRatedVersion, version, @"Expected lastVersionRated to be equal to given version");
    
}

- (void)test_whenUpdatingLastRatedVersion_itStoresTheLastVersionRated {
    
    NSString *version = @"3.0.0";
    
    dataSource.lastRatedVersion = version;
    
    OCMVerify([userDefaultsMock setObject:version forKey:kAppRatingsLastRatedVersion]);
    
}

- (void)test_givenEventsAreInStorage_events_getsTheEventsFromStorage {
    
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithDictionary:@{@"eventName": @2}];
    
    OCMStub([userDefaultsMock objectForKey:kAppRatingsEvents]).andReturn(events);
    
    XCTAssertEqualObjects(dataSource.events, events, @"Expected events to equal the events from NSUserDefaults");
    
}

- (void)test_givenNoEventsAreInStorage_events_returnsANewMutableDictionary {
    
    OCMStub([userDefaultsMock objectForKey:kAppRatingsEvents]).andReturn(nil);
    
    XCTAssertNotNil(dataSource.events, @"Expected events to be non-nil");
    XCTAssertEqual([dataSource.events count], 0, @"Expected there to be no events.");
    
}

- (void)test_whenUpdatingEvents_itStoresTheEvents {
    
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithDictionary:@{@"eventName": @2}];
    
    dataSource.events = events;
    
    OCMVerify([userDefaultsMock setObject:events forKey:kAppRatingsEvents]);
    
}

- (void)test_whenAddingANewEvent_itUpdatesTheStoredEvents {
    
    // use the actual NSUserDefaults for this test
    [userDefaultsMock stopMocking];
    [dataSource clearEvents];
    
    NSString *eventName = @"Test Event";
    
    [dataSource addEvent:eventName];
    
    XCTAssertEqual([dataSource.events[eventName] integerValue], 1, @"Expected event count to be set.");
    
}

- (void)test_whenAddingAnEvent_itUpdatesTheStoredEvents {
    
    // use the actual NSUserDefaults for this test
    [userDefaultsMock stopMocking];
    
    NSString *eventName = @"Test Event";
    
    NSMutableDictionary *initialEvents = [NSMutableDictionary dictionaryWithDictionary:@{eventName: @2}];
    
    dataSource.events = initialEvents;
    
    [dataSource addEvent:eventName];
    
    XCTAssertEqual([dataSource.events[eventName] integerValue], 3, @"Expected event count to be increased.");
    
}



@end
