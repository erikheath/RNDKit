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
#import "RNDBindingProcessorTestFramework.h"

@interface RNDBinderTests : XCTestCase

@end

@implementation RNDBinderTests

- (void)testRNDBinder {
    RNDPatternedStringProcessor *processor = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"F"];
    RNDPatternedStringProcessor *processorArg1 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"D"];
    RNDPatternedStringProcessor *processorArg2 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"E"];
    [processor.processorArguments addObject:processorArg1];
    [processor.processorArguments addObject:processorArg2];

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
    
    NSError *error;
    binder.monitorsObserver = YES;
    XCTAssertNil(binder.bindingObjectValue);
    XCTAssertFalse(binder.bound);
    XCTAssertFalse([binder bind:&error]);
    XCTAssertNotNil(error);
    binder.monitorsObserver = NO;
    
    error = nil;
    
    [binder.inflowBindings addObject:processor];
    XCTAssertNil(binder.bindingObjectValue);
    XCTAssertTrue([binder bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(binder.bindingObjectValue);
    XCTAssertEqualObjects(@"Hello World!", binder.bindingObjectValue);
    XCTAssertTrue([binder unbind:&error]);
    XCTAssertNil(error);
    
    binder.binderMode = RNDKeyedValueMode;
    XCTAssertNil(binder.bindingObjectValue);
    XCTAssertTrue([binder bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(binder.bindingObjectValue);
    XCTAssertEqualObjects(@{@"0":@"Hello World!"}, binder.bindingObjectValue);
    XCTAssertTrue([binder unbind:&error]);
    XCTAssertNil(error);

    binder.binderMode = RNDOrderedKeyedValueMode;
    XCTAssertNil(binder.bindingObjectValue);
    XCTAssertTrue([binder bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(binder.bindingObjectValue);
    XCTAssertEqualObjects(@[@{@"0":@"Hello World!"}], binder.bindingObjectValue);
    XCTAssertTrue([binder unbind:&error]);
    XCTAssertNil(error);
    
    // Observer
    NSMutableDictionary *observerDictionary = [[NSMutableDictionary alloc] init];
    binder.binderMode = RNDValueOnlyMode;
    binder.observerKey =  @"observerProperty";
    binder.observer = observerDictionary;
    XCTAssertEqual(0, observerDictionary.count);
    XCTAssertNil(binder.bindingObjectValue);
    XCTAssertTrue([binder bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(binder.bindingObjectValue);
    XCTKVOExpectation *expectation = [[XCTKVOExpectation alloc] initWithKeyPath:@"observerProperty"
                                                                         object:observerDictionary
                                                                  expectedValue:@"Hello World!"];

    id observedObject = processor.observedObject;
    [observedObject setValue:@"newProperty" forKeyPath:@"testController.testProperty"];
    XCTWaiterResult waitResult = [XCTWaiter waitForExpectations:@[expectation] timeout:3.0];
    XCTAssertEqual(waitResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects(observerDictionary[@"observerProperty"], @"Hello World!");
    XCTAssertTrue([binder unbind:&error]);
    XCTAssertNil(error);
    
    RNDBindingProcessor *outflowProcessor = [RNDBindingProcessorTestFramework processorWithProfile:@"A"];
    outflowProcessor.observedObject = observedObject;
    outflowProcessor.observedObjectKeyPath = @"testProperty";
    outflowProcessor.controllerKey = @"testController";
    outflowProcessor.monitorsObservedObject = NO;
    [binder.outflowBindings addObject:outflowProcessor];
    [binder.inflowBindings removeAllObjects];
    RNDBindingProcessor *inflowProcessor = [RNDBindingProcessorTestFramework processorWithProfile:@"A"];
    inflowProcessor.observedObject = observedObject;
    inflowProcessor.observedObjectKeyPath = @"testProperty";
    inflowProcessor.controllerKey = @"testController";
    inflowProcessor.monitorsObservedObject = YES;
    [binder.inflowBindings addObject:inflowProcessor];
    binder.monitorsObserver = YES;
    binder.bindingName = @"Test Binding";
    
    XCTAssertTrue([binder bind:&error]);
    XCTAssertNil(error);
    XCTKVOExpectation *observedExpectation = [[XCTKVOExpectation alloc] initWithKeyPath:@"testController.testProperty" object:observedObject expectedValue:@"additionalProperty"];
    observerDictionary[@"observerProperty"] = @"additionalProperty";
    XCTWaiterResult observedWaitResult = [XCTWaiter waitForExpectations:@[observedExpectation] timeout:3.0];
    XCTAssertEqual(observedWaitResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects([observedObject valueForKeyPath:@"testController.testProperty"], @"additionalProperty");

    
}

@end
