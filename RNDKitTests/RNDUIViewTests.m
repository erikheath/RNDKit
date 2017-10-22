//
//  RNDUIViewTests.m
//  RNDKitTests
//
//  Created by Erikheath Thomas on 10/18/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RNDKit/RNDKit.h>
#import <objc/runtime.h>
#import <CoreData/CoreData.h>

@interface RNDUIViewTests : XCTestCase

@end

@implementation RNDUIViewTests

#pragma mark - Test Binding Creation

- (void)testUIViewKeyValueBindingCreation {
    /////////////// Setup
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
    RNDObjectController *controller = [[RNDObjectController alloc] init];
    [controller prepareContent];
    [controller setValue:@YES forKeyPath:@"content.hideView"];
    
    NSArray<RNDBindingName> *defaultBindings = [UIView defaultBindings];
    XCTAssertEqualObjects(defaultBindings, @[RNDHiddenBindingName]);
    
    NSArray<RNDBindingName> *exposedBindings = [UIView exposedBindings];
    XCTAssertEqualObjects(exposedBindings, defaultBindings);
    
    NSArray<RNDBindingName> *allExposedBindings = [UIView allExposedBindings];
    XCTAssertEqualObjects(exposedBindings, allExposedBindings);
    
    [UIView exposeBinding:RNDEnabledBindingName];
    exposedBindings = [UIView exposedBindings];
    NSArray<RNDBindingName> *testBindings = @[RNDHiddenBindingName, RNDEnabledBindingName];
    XCTAssertEqualObjects(exposedBindings, testBindings);
    
    //Test for both an exposed binding and an unexposed binding
    XCTAssertNil([testView infoForBinding:RNDHiddenBindingName]); // Exposed
    XCTAssertNil([testView infoForBinding:RNDDataBindingName]); // Unexposed
    
    id optionDescriptions = [testView optionDescriptionsForBinding:RNDHiddenBindingName];
    XCTAssertTrue([optionDescriptions isKindOfClass:[NSArray class]]);
    XCTAssertTrue([[optionDescriptions firstObject] isKindOfClass:[NSAttributeDescription class]]);
    
    Class valueClass = [testView valueClassForBinding:RNDHiddenBindingName];
    XCTAssertNil(valueClass);
    
    [testView bind:RNDHiddenBindingName toObject:controller withKeyPath:@"content.hideView" options:nil];
    XCTAssertNotNil([testView infoForBinding:RNDHiddenBindingName]);
    XCTAssertTrue([[controller modelKeyToDependentKeyTable] count] == 1);
    XCTAssertTrue([[controller modelKeyToDependentKeyTable][@"hideView"] isKindOfClass:[NSSet class]]);
    XCTAssertEqualObjects([[controller modelKeyToDependentKeyTable][@"hideView"] anyObject], @"content.hideView");
    XCTAssertTrue([[controller dependentKeyToModelKeyTable] count] == 1);
    XCTAssertTrue([[controller dependentKeyToModelKeyTable] isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects([controller dependentKeyToModelKeyTable][@"content.hideView"], @"hideView");
    
    
    controller.content[@"hideView"] = @NO;
    XCTAssertFalse(testView.hidden);
    
    controller.content[@"hideView"] = @YES;
    XCTAssertTrue(testView.hidden);
    
    [testView setValue:@NO forKey:@"hidden"];
    XCTAssertEqualObjects(controller.content[@"hideView"], @NO);
    
    testView.hidden = @YES;
    XCTAssertEqualObjects(controller.content[@"hideView"], @YES);
    
    [testView unbind:RNDHiddenBindingName];
    XCTAssertNil([testView infoForBinding:RNDHiddenBindingName]);
    
}

@end
