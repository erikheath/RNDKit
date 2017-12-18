//
//  RNDSelectionTests.m
//  RNDKitTests
//
//  Created by Erikheath Thomas on 10/18/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RNDKit/RNDKit.h>
#import <objc/runtime.h>
#import <CoreData/CoreData.h>

@interface RNDBinderTests : XCTestCase

@end

@implementation RNDBinderTests

- (void)testRNDBinder {
    
    RNDBinder *binder = [[RNDBinder alloc] init];
    binder.binderMode = RNDValueOnlyMode;
    binder.unwrapSingleValue = YES;
    XCTAssertNotNil(binder);
    XCTAssertNil(binder.binderIdentifier);
    XCTAssertNotNil(binder.inflowBindings);
    XCTAssertNotNil(binder.outflowBindings);
    XCTAssertNil(binder.boundInflowBindings);
    XCTAssertNil(binder.boundInflowBindings);
    XCTAssertNil(binder.observer);
    XCTAssertNil(binder.observerKey);
    XCTAssertEqual(binder.binderMode, RNDValueOnlyMode);
    XCTAssertFalse(binder.monitorsObserver);
    XCTAssertNotNil(binder.syncQueue);
    XCTAssertNil(binder.bindingName);
    XCTAssertNil(binder.bindingObjectValue);
    XCTAssertNil(binder.nullPlaceholder);
    XCTAssertNil(binder.multipleSelectionPlaceholder);
    XCTAssertNil(binder.noSelectionPlaceholder);
    XCTAssertNil(binder.notApplicablePlaceholder);
    XCTAssertNil(binder.nilPlaceholder);
    XCTAssertFalse(binder.filtersNilValues);
    XCTAssertFalse(binder.filtersMarkerValues);
    XCTAssertTrue(binder.unwrapSingleValue);
    XCTAssertFalse(binder.mutuallyExclusive);
    
    XCTAssertNil(binder.bindingObjectValue);
    XCTAssertFalse(binder.bound);
    [binder bind];
    XCTAssertTrue(binder.isBound);
    XCTAssertNil(binder.bindingObjectValue);
    [binder unbind];
    XCTAssertFalse(binder.bound);
    XCTAssertNil(binder.bindingObjectValue);
    
    binder.monitorsObserver = YES;
    XCTAssertNil(binder.bindingObjectValue);
    XCTAssertFalse(binder.bound);
    NSError *error;
    XCTAssertFalse([binder bind:&error]);
    XCTAssertNotNil(error);
    binder.monitorsObserver = NO;
    
}

@end
