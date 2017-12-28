//
//  RNDBindingsTests.m
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


@interface RNDBindingProcessorTests : XCTestCase

@end

@implementation RNDBindingProcessorTests

- (void)runBindingTests:(RNDBindingProcessor *)processor {
    NSError *error;

    // Test Binding
    [processor bind];
    XCTAssertTrue(processor.isBound);
    
    // Test Unbinding
    [processor unbind];
    XCTAssertFalse(processor.isBound);
    
    // Test Binding
    [processor bind];
    XCTAssertTrue(processor.isBound);
    
    // Test Rebinding
    [processor bind];
    XCTAssertTrue(processor.isBound);
    
    // Test Unbinding
    [processor unbind];
    XCTAssertFalse(processor.isBound);
    
    // Test Repeated Unbinding
    [processor unbind];
    XCTAssertFalse(processor.isBound);
    
    // Test Binding with error
    error = NULL;
    BOOL status = [processor bind:&error];
    XCTAssertTrue(processor.isBound);
    XCTAssertTrue(status);
    XCTAssertNil(error);
    
    // Test Unbinding with error
    error = NULL;
    status = [processor unbind:&error];
    XCTAssertFalse(processor.isBound);
    XCTAssertTrue(status);
    XCTAssertNil(error);
    
    // Test Binding with error
    error = NULL;
    status = [processor bind:&error];
    XCTAssertTrue(processor.isBound);
    XCTAssertTrue(status);
    XCTAssertNil(error);
    
    // Test Rebinding with error
    error = NULL;
    status = [processor bind:&error];
    XCTAssertTrue(processor.isBound);
    XCTAssertFalse(status);
    XCTAssertNotNil(error);
    
    // Test Unbinding with error
    error = NULL;
    status = [processor unbind:&error];
    XCTAssertFalse(processor.isBound);
    XCTAssertTrue(status);
    XCTAssertNil(error);
    
    // Test Repeated Unbinding with error
    error = NULL;
    status = [processor unbind:&error];
    XCTAssertFalse(processor.isBound);
    XCTAssertTrue(status);
    XCTAssertNil(error);

}

- (void)testProfileA {
    RNDBindingProcessor *processor = [RNDBindingProcessorTestFramework processorWithProfile:@"A"];
    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNil(processor.observedObject);
    XCTAssertNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertFalse(processor.monitorsObservedObject);
    XCTAssertNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNil(processor.observedObjectEvaluationValue);
    
    [self runBindingTests:processor];
    
    NSError *error;
    
    // TODO: FAILED EVALUATION
    processor.observedObjectEvaluator = (RNDPredicateProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"G"];
    [processor.observedObjectEvaluator.processorArguments addObject:[RNDBindingProcessorTestFramework processorWithProfile:@"F"]];
    processor.observedObjectEvaluator.processorArguments[0].argumentName = @"ARG3"
    ;
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);
    processor.observedObjectEvaluator = nil;
    
    // NIL TESTING
    processor.observedObject = nil;
    processor.observedObjectKeyPath = nil;
    processor.nilPlaceholder = [RNDBindingProcessorTestFramework processorWithProfile:@"B"];
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(processor.bindingObjectValue);
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    processor.nilPlaceholder = [RNDBindingProcessorTestFramework processorWithProfile:@"C"];
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"propertyValue");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    // NULL TESTING
    processor.nullPlaceholder = [RNDBindingProcessorTestFramework processorWithProfile:@"D"];
    
    processor.observedObject = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"testProperty"];
    processor.observedObjectKeyPath = @"testProperty";
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"Hello");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    // NO SELECTION TESTING
    processor.noSelectionPlaceholder = [RNDBindingProcessorTestFramework processorWithProfile:@"E"];
    processor.observedObject = [NSMutableDictionary dictionaryWithObject:RNDBindingNoSelectionMarker
                                                                  forKey:@"testProperty"];
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"World");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    // NOT APPLICABLE TESTING
    processor.notApplicablePlaceholder = [RNDBindingProcessorTestFramework processorWithProfile:@"F"];
    processor.observedObject = [NSMutableDictionary dictionaryWithObject:RNDBindingNotApplicableMarker
                                                                  forKey:@"testProperty"];
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"$ARG1 $ARG2!");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    // MULTIPLE SELECTION TESTING
    processor.multipleSelectionPlaceholder = [RNDBindingProcessorTestFramework processorWithProfile:@"F"];
    [processor.multipleSelectionPlaceholder.processorArguments addObject:[RNDBindingProcessorTestFramework processorWithProfile:@"D"]];
    [processor.multipleSelectionPlaceholder.processorArguments addObject:[RNDBindingProcessorTestFramework processorWithProfile:@"E"]];
    processor.observedObject = [NSMutableDictionary dictionaryWithObject:RNDBindingMultipleValuesMarker
                                                                  forKey:@"testProperty"];
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"Hello World!");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

}


- (void)testProfileB {
    RNDBindingProcessor *processor = [RNDBindingProcessorTestFramework processorWithProfile:@"B"];
    
    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNotNil(processor.observedObject);
    XCTAssertNotNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue(processor.monitorsObservedObject);
    XCTAssertNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNotNil(processor.observedObjectEvaluationValue);
    
    [self runBindingTests:processor];
    
}

- (void)testProfileC {
    RNDBindingProcessor *processor = [RNDBindingProcessorTestFramework processorWithProfile:@"C"];
    
    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNotNil(processor.observedObject);
    XCTAssertNotNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue(processor.monitorsObservedObject);
    XCTAssertNotNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNotNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNotNil(processor.observedObjectEvaluationValue);
    
    [self runBindingTests:processor];
    
    NSError *error;
    
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"propertyValue");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);
    XCTAssertNil(processor.bindingObjectValue);
}

- (void)testProfileD {
    RNDPatternedStringProcessor *processor = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"D"];
    
    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNotNil(processor.observedObject);
    XCTAssertNotNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue(processor.monitorsObservedObject);
    XCTAssertNotNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNotNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNotNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNotNil(processor.observedObjectEvaluationValue);
    XCTAssertNotNil(processor.patternTemplate);
    
    [self runBindingTests:processor];
    
    NSError *error;
    
    // TODO: Add a Binder/Observer/ObservedObject
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"Hello");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);
    XCTAssertNil(processor.bindingObjectValue);
}

- (void)testProfileE {
    RNDPatternedStringProcessor *processor = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"E"];
    
    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNotNil(processor.observedObject);
    XCTAssertNotNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue(processor.monitorsObservedObject);
    XCTAssertNotNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNotNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNotNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNotNil(processor.observedObjectEvaluationValue);
    XCTAssertNotNil(processor.patternTemplate);
    
    [self runBindingTests:processor];
    
    NSError *error;

    // TODO: Add a Binder/Observer/ObservedObject
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"World");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);
    XCTAssertNil(processor.bindingObjectValue);
}

- (void)testProfileF {
    RNDPatternedStringProcessor *processor = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"F"];
    RNDPatternedStringProcessor *processorArg1 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"D"];
    RNDPatternedStringProcessor *processorArg2 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"E"];

    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNotNil(processor.observedObject);
    XCTAssertNotNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue(processor.monitorsObservedObject);
    XCTAssertNotNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNotNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNotNil(processor.observedObjectEvaluationValue);
    XCTAssertNotNil(processor.patternTemplate);
    
    [self runBindingTests:processor];
    
    NSError *error;

    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"$ARG1 $ARG2!");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);
    XCTAssertNil(processor.bindingObjectValue);
    
    [processor.processorArguments addObject:processorArg1];
    [processor.processorArguments addObject:processorArg2];
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"Hello World!");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

}

- (void)testProfileG {
    RNDPredicateProcessor *processor = (RNDPredicateProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"G"];
    RNDPatternedStringProcessor *processorArg1 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"D"];
    RNDPatternedStringProcessor *processorArg2 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"E"];
    RNDPatternedStringProcessor *processorArg3 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"F"];
    [processorArg3.processorArguments addObjectsFromArray:@[processorArg1, processorArg2]];
    processorArg3.argumentName = @"ARG3";
    
    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNotNil(processor.observedObject);
    XCTAssertNotNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue(processor.monitorsObservedObject);
    XCTAssertNotNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNotNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNotNil(processor.observedObjectEvaluationValue);
    XCTAssertNotNil(processor.predicateFormatString);
    
    [self runBindingTests:processor];

    NSError *error;
    
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, [NSPredicate predicateWithFormat:@"'Hello World!' = $ARG3"]);
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);
    XCTAssertNil(processor.bindingObjectValue);
    
    [processor.processorArguments addObject:processorArg3];
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, [NSPredicate predicateWithFormat:@"'Hello World!' = 'Hello World!'"]);
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    processor.processorOutputType = RNDCalculatedValueOutputType;
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertTrue([processor.bindingObjectValue boolValue]);
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

}

- (void)testProfileH {
    RNDRegExProcessor *processor = (RNDRegExProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"H"];

    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNil(processor.observedObject);
    XCTAssertNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertFalse(processor.monitorsObservedObject);
    XCTAssertNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNotNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNil(processor.observedObjectEvaluationValue);
    XCTAssertNotNil(processor.regExTemplate);
    XCTAssertNotNil(processor.replacementTemplate);
    
    [self runBindingTests:processor];

    // Construct an observed object using processors
    RNDPatternedStringProcessor *processorArg1 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"D"];
    RNDPatternedStringProcessor *processorArg2 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"E"];
    RNDPatternedStringProcessor *processorArg3 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"F"];
    [processorArg3.processorArguments addObjectsFromArray:@[processorArg1, processorArg2]];
    processorArg3.argumentName = @"ARG3";
    processorArg3.processorOutputType = RNDCalculatedValueOutputType;
    processor.observedObject = processorArg3;
    processor.observedObjectKeyPath = @"bindingObjectValue";
    
    NSError *error;
    XCTAssertNil(processor.bindingObjectValue);
    processor.processorOutputType = RNDCalculatedValueOutputType;
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"My World!");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);
    
}

- (void)testProfileI {
    RNDExpressionProcessor *processor = (RNDExpressionProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"I"];
    
    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNil(processor.observedObject);
    XCTAssertNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertFalse(processor.monitorsObservedObject);
    XCTAssertNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNotNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNil(processor.observedObjectEvaluationValue);
    XCTAssertNotNil(processor.expressionTemplate);
    
    [self runBindingTests:processor];

    NSError *error;
    XCTAssertNil(processor.bindingObjectValue);
    processor.processorOutputType = RNDCalculatedValueOutputType;
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(processor.bindingObjectValue);
}

- (void)testProfileJ {
    RNDInvocationProcessor *processor = (RNDInvocationProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"J"];
    
    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNil(processor.observedObject);
    XCTAssertNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertFalse(processor.monitorsObservedObject);
    XCTAssertNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNotNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNil(processor.observedObjectEvaluationValue);
    XCTAssertNotNil(processor.bindingSelectorString);
    
    [self runBindingTests:processor];
    
    NSError *error;
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor unbind:&error]);
    processor.processorOutputType = RNDCalculatedValueOutputType;
    
    RNDPatternedStringProcessor *processorArg1 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"D"];
    RNDPatternedStringProcessor *processorArg2 = (RNDPatternedStringProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"E"];

    [processor.processorArguments addObjectsFromArray:@[processorArg2]];
    processor.observedObject = processorArg1;
    processor.observedObjectKeyPath = @"bindingObjectValue";
    
    
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(processor.bindingObjectValue);

    
}

- (void)testProfileK {
    RNDAggregationProcessor *processor = (RNDAggregationProcessor *)[RNDBindingProcessorTestFramework processorWithProfile:@"K"];

    
    XCTAssertNotNil(processor);
    XCTAssertFalse(processor.isBound);
    XCTAssertNotNil(processor.syncQueue);
    XCTAssertNil(processor.observedObject);
    XCTAssertNil(processor.observedObjectKeyPath);
    XCTAssertNil(processor.observedObjectBindingIdentifier);
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertFalse(processor.monitorsObservedObject);
    XCTAssertNil(processor.controllerKey);
    XCTAssertNil(processor.binder);
    XCTAssertNotNil(processor.bindingName);
    XCTAssertNil(processor.nullPlaceholder);
    XCTAssertNil(processor.multipleSelectionPlaceholder);
    XCTAssertNil(processor.notApplicablePlaceholder);
    XCTAssertNil(processor.nilPlaceholder);
    XCTAssertNil(processor.noSelectionPlaceholder);
    XCTAssertNil(processor.argumentName);
    XCTAssertNil(processor.valueTransformerName);
    XCTAssertNil(processor.valueTransformer);
    XCTAssertNotNil(processor.processorArguments);
    XCTAssertNil(processor.observedObjectEvaluator);
    XCTAssertEqual(processor.processorOutputType, RNDRawValueOutputType);
    XCTAssertNotNil(processor.runtimeArguments);
    XCTAssertNotNil(processor.processorNodes);
    XCTAssertNil(processor.observedObjectEvaluationValue);
    
    [self runBindingTests:processor];
    
    NSError *error;
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(processor.bindingObjectValue);
    XCTAssertTrue([processor.bindingObjectValue isKindOfClass:[NSArray class]]);
    XCTAssertTrue([processor unbind:&error]);

    // TODO: Test different value modes
    // TODO: Test different filterings

}

@end

