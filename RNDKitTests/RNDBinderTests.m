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
    XCTAssertNotNil(binder);
    XCTAssertNil(binder.bindingIdentifier);
    XCTAssertNil(binder.bindingObject);
    XCTAssertNil(binder.bindingObjectKeyPath);
    XCTAssertFalse(binder.monitorsBindingObject);
    XCTAssertNotNil(binder.coordinator);
    XCTAssertNil(binder.bindingName);
    XCTAssertNil(binder.bindingValue);
    
    NSError *error;
    XCTAssertNil(binder.bindingValue);
    XCTAssertFalse(binder.bound);
    [binder bind:&error];
    XCTAssertTrue(binder.isBound);
    XCTAssertNil(binder.bindingValue);
    [binder unbind];
    XCTAssertFalse(binder.bound);
    XCTAssertNil(binder.bindingValue);
    
    error = nil;
    binder.monitorsBindingObject = YES;
    XCTAssertNil(binder.bindingValue);
    XCTAssertFalse(binder.bound);
    XCTAssertFalse([binder bind:&error]);
    XCTAssertNotNil(error);
    binder.monitorsBindingObject = NO;
    
    error = nil;
    
    binder.inflowProcessor = processor;
    XCTAssertNil(binder.bindingValue);
    XCTAssertNil(binder.bindingValue);
    XCTAssertTrue([binder bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(binder.bindingValue);
    XCTAssertEqualObjects(@"Hello World!", binder.bindingValue);
    XCTAssertTrue([binder unbind:&error]);
    XCTAssertNil(error);
    
    XCTAssertNil(binder.bindingValue);
    XCTAssertTrue([binder bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(binder.bindingValue);
    XCTAssertEqualObjects(@{@"0":@"Hello World!"}, binder.bindingValue);
    XCTAssertTrue([binder unbind:&error]);
    XCTAssertNil(error);

    XCTAssertNil(binder.bindingValue);
    XCTAssertTrue([binder bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(binder.bindingValue);
    XCTAssertEqualObjects(@[@{@"0":@"Hello World!"}], binder.bindingValue);
    XCTAssertTrue([binder unbind:&error]);
    XCTAssertNil(error);
    
    // Observer
    NSMutableDictionary *observerDictionary = [[NSMutableDictionary alloc] init];
    binder.bindingObjectKeyPath =  @"observerProperty";
    binder.bindingObject = observerDictionary;
    XCTAssertEqual(0, observerDictionary.count);
    XCTAssertNil(binder.bindingValue);
    XCTAssertTrue([binder bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(binder.bindingValue);
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
    
    // Test basic synchronization - Cocoa Bindings functionality replacement
    RNDBindingProcessor *outflowProcessor = [RNDBindingProcessorTestFramework processorWithProfile:@"A"];
    outflowProcessor.observedObject = observedObject;
    outflowProcessor.observedObjectKeyPath = @"testProperty";
    outflowProcessor.controllerKey = @"testController";
    outflowProcessor.monitorsObservedObject = NO;
    outflowProcessor.bindingName = @"outflowname";
    [binder.outflowProcessors addObject:outflowProcessor];
    RNDBindingProcessor *inflowProcessor = [RNDBindingProcessorTestFramework processorWithProfile:@"A"];
    inflowProcessor.observedObject = observedObject;
    inflowProcessor.observedObjectKeyPath = @"testProperty";
    inflowProcessor.controllerKey = @"testController";
    inflowProcessor.monitorsObservedObject = YES;
    inflowProcessor.bindingName = @"inflowname";
    binder.inflowProcessor = inflowProcessor;
    binder.monitorsBindingObject = YES;
    binder.bindingName = @"Test Binding";
    
    XCTAssertTrue([binder bind:&error]);
    XCTAssertNil(error);
    XCTKVOExpectation *observedExpectation = [[XCTKVOExpectation alloc] initWithKeyPath:@"testController.testProperty" object:observedObject expectedValue:@"additionalProperty"];
    observerDictionary[@"observerProperty"] = @"additionalProperty";
    XCTWaiterResult observedWaitResult = [XCTWaiter waitForExpectations:@[observedExpectation] timeout:3.0];
    XCTAssertEqual(observedWaitResult, XCTWaiterResultCompleted);
    XCTAssertEqualObjects([observedObject valueForKeyPath:@"testController.testProperty"], @"additionalProperty");
    XCTAssertTrue([binder unbind:&error]);
    XCTAssertNil(error);

    // Test that you can not use a binding twice.
    [binder.outflowProcessors addObject:inflowProcessor];
    XCTAssertFalse([binder bind:&error]);
    XCTAssertNotNil(error);
    
}

//- (void)testExpression {
//    // Test work with expressions
//    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
//    [observedObject setObject:@"property value" forKey:@"testController"];
//    NSExpression *expression = [NSExpression expressionForConstantValue:observedObject];
//    id expressionObject = [expression expressionValueWithObject:nil context:nil];
//    NSLog(@"%@", expressionObject);
//    expression = [NSExpression expressionForVariable:@"testController"];
//    expressionObject = [expression expressionValueWithObject:nil context:observedObject];
//    NSLog(@"%@", expressionObject);
//    expression = [NSExpression expressionWithFormat:@"CAST(535572163.32473397, 'NSDate')"];
//    expressionObject = [expression expressionValueWithObject:nil context:observedObject];
//    NSLog(@"%@", expressionObject);
//    expression = [NSExpression expressionWithFormat:@"CAST(CAST(CAST(535572163.32473397, 'NSDate'), 'NSString'), 'NSNumber')"];
//    expressionObject = [expression expressionValueWithObject:nil context:observedObject];
//    NSLog(@"%@", expressionObject);
//
//    NSExpression *leftExpression = [NSExpression expressionWithFormat:@"CAST(535572163.32473397, 'NSDate')"];
//    NSExpression *rightExpression = [NSExpression expressionWithFormat:@"now()"];
//    [observedObject setObject:leftExpression forKey:@"leftExpression"];
//    [observedObject setObject:rightExpression forKey:@"rightExpression"];
//    expression = [NSExpression expressionWithFormat:@"{$leftExpression, $rightExpression}"];
//    expressionObject = [expression expressionValueWithObject:nil context:observedObject];
//    NSLog(@"%@", expressionObject);
//
//    expression = [NSExpression expressionWithFormat:@"{CAST(535572163.32473397, 'NSDate'), now()}"];
//    expressionObject = [expression expressionValueWithObject:nil context:observedObject];
//    NSLog(@"%@", expressionObject);
//
//    expression = [NSExpression expressionWithFormat:@"$rawDate"];
//    NSDate *rawDate = [NSDate date];
//    [observedObject removeAllObjects];
//    [observedObject setObject:rawDate forKey:@"rawDate"];
//    expressionObject = [expression expressionValueWithObject:nil context:observedObject];
//    NSLog(@"%@", expressionObject);
//
//    expression = [NSExpression expressionWithFormat:@"10203040"];
//    expressionObject = [expression expressionValueWithObject:nil context:nil];
//    NSLog(@"%@", expressionObject);
//
//    NSSet *setObject = [NSSet setWithObject:@"specialSetObject"];
//    NSDictionary *dictionaryObject = @{@"keyOne":@"otherSetObject", @"keyTwo":@"lessSpecialObject"};
//    expression = [NSExpression expressionWithFormat:@"$setObject MINUS $dictionaryObject"];
//    [observedObject removeAllObjects];
//    [observedObject setObject:setObject forKey:@"setObject"];
//    [observedObject setObject:dictionaryObject forKey:@"dictionaryObject"];
//    expressionObject = [expression expressionValueWithObject:nil context:observedObject];
//    NSLog(@"%@", expressionObject);
//
//    expression = [NSExpression expressionWithFormat:@"SELF"];
//    expressionObject = [expression expressionValueWithObject:observedObject context:nil];
//    NSLog(@"%@", expressionObject);
//
//}

@end
