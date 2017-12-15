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



@interface RNDBindingProcessorTests : XCTestCase

@end

@implementation RNDBindingProcessorTests

- (RNDBindingProcessor *)processorWithProfile:(NSString *)profileName {
    SEL profileSelector = NSSelectorFromString([@"profile" stringByAppendingString:profileName]);
    return [self performSelector:profileSelector];
}

- (RNDBindingProcessor *)profileA {
    return [[RNDBindingProcessor alloc] init];
}

- (RNDBindingProcessor *)profileB {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:[NSObject new] forKey:@"testProperty"];
    RNDBindingProcessor *profile = [[RNDBindingProcessor alloc] init];
    profile.observedObject = observedObject;
    profile.observedObjectKeyPath = @"testProperty";
    profile.monitorsObservedObject = YES;
    
    return profile;
}

- (RNDBindingProcessor *)profileC {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:@"propertyValue" forKey:@"testProperty"];
    NSMutableDictionary *observedController = [NSMutableDictionary dictionary];
    [observedController setObject:observedObject forKey:@"testController"];
    
    RNDBindingProcessor *profile = [[RNDBindingProcessor alloc] init];
    profile.observedObject = observedController;
    profile.observedObjectKeyPath = @"testProperty";
    profile.controllerKey = @"testController";
    profile.monitorsObservedObject = YES;
    profile.bindingName = @"RNDTestBinding";

    return profile;
}

- (RNDPatternedStringProcessor *)profileD {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:[NSObject new] forKey:@"testProperty"];
    NSMutableDictionary *observedController = [NSMutableDictionary dictionary];
    [observedController setObject:observedObject forKey:@"testController"];

    RNDPatternedStringProcessor *profile = [[RNDPatternedStringProcessor alloc] init];
    profile.observedObject = observedController;
    profile.observedObjectKeyPath = @"testProperty";
    profile.controllerKey = @"testController";
    profile.monitorsObservedObject = YES;
    profile.bindingName = @"RNDTestBinding";
    profile.patternTemplate = @"Hello";
    profile.argumentName = @"$ARG1";

    return profile;
}

- (RNDPatternedStringProcessor *)profileE {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:[NSObject new] forKey:@"testProperty"];
    NSMutableDictionary *observedController = [NSMutableDictionary dictionary];
    [observedController setObject:observedObject forKey:@"testController"];
    
    RNDPatternedStringProcessor *profile = [[RNDPatternedStringProcessor alloc] init];
    profile.observedObject = observedController;
    profile.observedObjectKeyPath = @"testProperty";
    profile.controllerKey = @"testController";
    profile.monitorsObservedObject = YES;
    profile.bindingName = @"RNDTestBinding";
    profile.patternTemplate = @"World";
    profile.argumentName = @"$ARG2";
    
    return profile;
}

- (RNDPatternedStringProcessor *)profileF {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:[NSObject new] forKey:@"testProperty"];
    NSMutableDictionary *observedController = [NSMutableDictionary dictionary];
    [observedController setObject:observedObject forKey:@"testController"];
    
    RNDPatternedStringProcessor *profile = [[RNDPatternedStringProcessor alloc] init];
    profile.observedObject = observedController;
    profile.observedObjectKeyPath = @"testProperty";
    profile.controllerKey = @"testController";
    profile.monitorsObservedObject = YES;
    profile.bindingName = @"RNDTestBinding";
    profile.patternTemplate = @"$ARG1 $ARG2!";
    
    return profile;
}

- (RNDPredicateProcessor *)profileG {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:[NSObject new] forKey:@"testProperty"];
    NSMutableDictionary *observedController = [NSMutableDictionary dictionary];
    [observedController setObject:observedObject forKey:@"testController"];
    
    RNDPredicateProcessor *profile = [[RNDPredicateProcessor alloc] init];
    profile.observedObject = observedController;
    profile.observedObjectKeyPath = @"testProperty";
    profile.controllerKey = @"testController";
    profile.monitorsObservedObject = YES;
    profile.bindingName = @"RNDTestBinding";
    profile.predicateFormatString = @"'Hello World!' = $ARG3";

    return profile;
}

- (RNDRegExProcessor *)profileH {
    RNDRegExProcessor *profile = [[RNDRegExProcessor alloc] init];
    profile.bindingName = @"RNDTestBinding";
    profile.regExTemplate = @"(Hello)(.*)";
    profile.replacementTemplate = @"My$2";
    
    return profile;
}

- (RNDExpressionProcessor *)profileI {
    RNDExpressionProcessor *profile = [[RNDExpressionProcessor alloc] init];
    profile.bindingName = @"RNDTestBinding";
    profile.expressionTemplate = @"now()";
    return profile;
}

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
    RNDBindingProcessor *processor = [self processorWithProfile:@"A"];
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
    processor.observedObjectEvaluator = (RNDPredicateProcessor *)[self processorWithProfile:@"G"];
    [processor.observedObjectEvaluator.processorArguments addObject:[self processorWithProfile:@"F"]];
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
    processor.nilPlaceholder = [self processorWithProfile:@"B"];
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertNotNil(processor.bindingObjectValue);
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    processor.nilPlaceholder = [self processorWithProfile:@"C"];
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"propertyValue");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    // NULL TESTING
    processor.nullPlaceholder = [self processorWithProfile:@"D"];
    
    processor.observedObject = [NSMutableDictionary dictionaryWithObject:[NSNull null] forKey:@"testProperty"];
    processor.observedObjectKeyPath = @"testProperty";
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"Hello");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    // NO SELECTION TESTING
    processor.noSelectionPlaceholder = [self processorWithProfile:@"E"];
    processor.observedObject = [NSMutableDictionary dictionaryWithObject:RNDBindingNoSelectionMarker
                                                                  forKey:@"testProperty"];
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"World");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    // NOT APPLICABLE TESTING
    processor.notApplicablePlaceholder = [self processorWithProfile:@"F"];
    processor.observedObject = [NSMutableDictionary dictionaryWithObject:RNDBindingNotApplicableMarker
                                                                  forKey:@"testProperty"];
    XCTAssertNil(processor.bindingObjectValue);
    XCTAssertTrue([processor bind:&error]);
    XCTAssertNil(error);
    XCTAssertEqualObjects(processor.bindingObjectValue, @"$ARG1 $ARG2!");
    XCTAssertTrue([processor unbind:&error]);
    XCTAssertNil(error);

    // MULTIPLE SELECTION TESTING
    processor.multipleSelectionPlaceholder = [self processorWithProfile:@"F"];
    [processor.multipleSelectionPlaceholder.processorArguments addObject:[self processorWithProfile:@"D"]];
    [processor.multipleSelectionPlaceholder.processorArguments addObject:[self processorWithProfile:@"E"]];
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
    RNDBindingProcessor *processor = [self processorWithProfile:@"B"];
    
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
    RNDBindingProcessor *processor = [self processorWithProfile:@"C"];
    
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
    RNDPatternedStringProcessor *processor = (RNDPatternedStringProcessor *)[self processorWithProfile:@"D"];
    
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
    RNDPatternedStringProcessor *processor = (RNDPatternedStringProcessor *)[self processorWithProfile:@"E"];
    
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
    RNDPatternedStringProcessor *processor = (RNDPatternedStringProcessor *)[self processorWithProfile:@"F"];
    RNDPatternedStringProcessor *processorArg1 = (RNDPatternedStringProcessor *)[self processorWithProfile:@"D"];
    RNDPatternedStringProcessor *processorArg2 = (RNDPatternedStringProcessor *)[self processorWithProfile:@"E"];

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
    RNDPredicateProcessor *processor = (RNDPredicateProcessor *)[self processorWithProfile:@"G"];
    RNDPatternedStringProcessor *processorArg1 = (RNDPatternedStringProcessor *)[self processorWithProfile:@"D"];
    RNDPatternedStringProcessor *processorArg2 = (RNDPatternedStringProcessor *)[self processorWithProfile:@"E"];
    RNDPatternedStringProcessor *processorArg3 = (RNDPatternedStringProcessor *)[self processorWithProfile:@"F"];
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
    RNDRegExProcessor *processor = (RNDRegExProcessor *)[self processorWithProfile:@"H"];

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
    RNDPatternedStringProcessor *processorArg1 = (RNDPatternedStringProcessor *)[self processorWithProfile:@"D"];
    RNDPatternedStringProcessor *processorArg2 = (RNDPatternedStringProcessor *)[self processorWithProfile:@"E"];
    RNDPatternedStringProcessor *processorArg3 = (RNDPatternedStringProcessor *)[self processorWithProfile:@"F"];
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
    RNDExpressionProcessor *processor = (RNDExpressionProcessor *)[self processorWithProfile:@"I"];
    
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
    
}

- (void)testProfileK {
    
}

@end

