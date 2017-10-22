//
//  RNDControllerTests.m
//  RNDKitTests
//
//  Created by Erikheath Thomas on 10/18/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RNDKit/RNDKit.h>
#import <objc/runtime.h>
#import <CoreData/CoreData.h>

@interface RNDControllerTests : XCTestCase

@property (readonly, nonnull) NSDictionary *collectionPropertiesDictionary;
@property (readonly, nonnull) NSArray *boolPropertiesArray;

@end

@implementation RNDControllerTests

@synthesize collectionPropertiesDictionary = _collectionPropertiesDictionary;
@synthesize boolPropertiesArray = _boolPropertiesArray;

#pragma mark - Test Utilities

static NSString *classUnderTestName = @"Object Controller";

- (NSDictionary *)collectionPropertiesDictionary {
    if (_collectionPropertiesDictionary == nil) {
        _collectionPropertiesDictionary = @{@"editorSet":@"NSMutableSet", @"declaredKeySet":@"NSMutableSet", @"dependentKeyToModelKeyTable":@"NSMutableDictionary", @"modelKeyToDependentKeyTable":@"NSMutableDictionary", @"modelKeysToRefreshEachTime":@"NSMutableSet"};
    }
    return _collectionPropertiesDictionary;
}

- (NSArray *)boolPropertiesArray {
    if (_boolPropertiesArray == nil) {
        _boolPropertiesArray = @[@"alwaysPresentsApplicationModalAlerts", @"refreshesAllModelKeys", @"multipleObservedModelObjects", @"editing"];
    }
    return _boolPropertiesArray;
}

- (void)baseRequirementsForObjectProperty:(id)propertyUnderTest named:(NSString *)propertyUnderTestName class:(Class)propertyUnderTestClass condition:(NSString *)creationCondition {
    NSString *propertyUnderTestClassName = NSStringFromClass(propertyUnderTestClass);
    objc_property_t declaredProperty = class_getProperty([RNDObjectController class], [propertyUnderTestName cStringUsingEncoding:NSUTF8StringEncoding]);
    XCTAssertFalse(declaredProperty == NULL, @"The property %@ must exist in %@", propertyUnderTestName, classUnderTestName);
    XCTAssertNotNil(propertyUnderTest, @"%@ %@ property should not be nil %@", classUnderTestName, propertyUnderTestName, creationCondition);
    XCTAssertTrue([propertyUnderTest isKindOfClass:propertyUnderTestClass], @"%@ %@ property should be of type %@ %@", classUnderTestName, propertyUnderTestName, propertyUnderTestClassName, creationCondition);
}

- (void)baseRequirementsForBOOLProperty:(BOOL)propertyValue named:(NSString *)propertyUnderTestName expectedValue:(BOOL)expectedValue condition:(NSString *)creationCondition {
    objc_property_t declaredProperty = class_getProperty([RNDObjectController class], [propertyUnderTestName cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString *attributes = [NSString stringWithCString:property_getAttributes(declaredProperty) encoding:NSUTF8StringEncoding];
    XCTAssertFalse(declaredProperty == NULL, @"The property %@ must exist in %@", propertyUnderTestName, classUnderTestName);
    XCTAssertTrue(attributes.length > 1, @"%@ %@ property is malformed.", classUnderTestName, propertyUnderTestName);
    XCTAssertTrue([attributes rangeOfString:@"TB" options:0 range:NSMakeRange(0, 2)].location != NSNotFound, @"%@ %@ property should be of type BOOL %@", classUnderTestName, propertyUnderTestName, creationCondition);
    XCTAssertTrue(propertyValue == expectedValue, @"%@ %@ should be %i %@", classUnderTestName, propertyUnderTestName, expectedValue, creationCondition);
}

- (void)collection:(id)collection named:(NSString *)collectionName shouldHave:(NSUInteger)members forCondition:(NSString *)condition {
    XCTAssertTrue([collection count] == members, @"%@ %@ property should have %lu members %@", classUnderTestName, collectionName, members, condition);
}

- (void)object:(id)object collectionProperties:(NSDictionary *)propertiesDictionary hasValidStateWithCount:(NSUInteger)count forCondition:(NSString *)condition {
    for (NSString *propertyUnderTestName in propertiesDictionary) {
        NSString *propertyUnderTestClassName = propertiesDictionary[propertyUnderTestName];
        id propertyUnderTest = [object valueForKey:propertyUnderTestName];
        Class propertyUnderTestClass = NSClassFromString(propertyUnderTestClassName);
        [self baseRequirementsForObjectProperty:propertyUnderTest named:propertyUnderTestName class:propertyUnderTestClass condition:condition];
        [self collection:propertyUnderTest named:propertyUnderTestName shouldHave:count forCondition:condition];
    }
}

- (void)object:(id)object boolProperties:(NSArray *)propertiesArray hasValidStateWithExpectedValue:(BOOL)boolValue forCondition:(NSString *)condition {
    for (NSString *propertyUnderTestName in propertiesArray) {
        BOOL propertyUnderTest = [[object valueForKey:propertyUnderTestName] boolValue];
        [self baseRequirementsForBOOLProperty:propertyUnderTest named:propertyUnderTestName expectedValue:boolValue condition:condition];
    }
}

#pragma mark - Test Object Lifecycle

// Create a controller object without a content object
- (void)testRNDControllerCreationBasic {
    /////////////// Setup
    RNDObjectController *controller = [[RNDObjectController alloc] init];
    NSString *creationCondition = @"when created using alloc - init.";
    
    // Standards: Existence, Basic Configuration
    XCTAssertNotNil(controller, @"%@ should not be nil %@", classUnderTestName, creationCondition);
    [self object:controller collectionProperties:self.collectionPropertiesDictionary hasValidStateWithCount:0 forCondition:creationCondition];
    [self object:controller boolProperties:self.boolPropertiesArray hasValidStateWithExpectedValue:NO forCondition:creationCondition];
    XCTAssertTrue(controller.controllerType == RNDClassController, @"%@ should be class type %@", classUnderTestName, creationCondition);
}

// Create a controller object from an archived version.
- (void)testRNDControllerCreationFromCoder {
    /////////////// Setup initWithCoder: mutable dictionary value encoded for content
    NSMutableDictionary *contentDictionary = [NSMutableDictionary dictionaryWithDictionary: @{@"title":@"Encode / Decoce Test", @"subTitle":@"Unit tests for RNDController Object"}];
    RNDObjectController *controller = [[RNDObjectController alloc] initWithContent:contentDictionary];
    controller.controllerType = RNDProxyController;
    NSString *creationCondition = @"when created using alloc - initWithCoder and coder is not nil.";
    
    // Encode / Decode of object
    NSData *archivedObject = [NSKeyedArchiver archivedDataWithRootObject:controller];
    XCTAssertNotNil(archivedObject, @"Encoded %@ should not be nil when archived.", classUnderTestName);
    RNDObjectController *decodedController = [NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
    
    // Standards: Existence, Basic Configuration
    XCTAssertNotNil(decodedController, @"Decoded %@ should not be nil when unarchived and %@.", classUnderTestName, creationCondition);
    NSMutableDictionary *testDictionary = [NSMutableDictionary dictionaryWithDictionary:self.collectionPropertiesDictionary];
    [testDictionary removeObjectForKey:@"content"];
    [self object:controller collectionProperties:testDictionary hasValidStateWithCount:0 forCondition:creationCondition];
    [self object:controller collectionProperties:@{@"content":@"NSMutableDictionary"} hasValidStateWithCount:2 forCondition:creationCondition];
    [self object:controller boolProperties:self.boolPropertiesArray hasValidStateWithExpectedValue:NO forCondition:creationCondition];
    XCTAssertTrue(controller.controllerType == RNDProxyController, @"%@ should be proxy type %@", classUnderTestName, creationCondition);
}

#pragma mark - Test Object Configurations

- (void)testObjectEditingRegistration {
    /////////////// Setup
    RNDObjectController *controller = [[RNDObjectController alloc] init];
//    NSString *creationCondition = @"when created using alloc - init.";
    
    id<RNDEditor> editor = (id<RNDEditor>)[NSObject new];
    [controller objectDidBeginEditing:editor];
    XCTAssert(controller.editorSet.count == 1);
    XCTAssertEqualObjects(controller.editorSet.anyObject, editor);
    XCTAssertNoThrow([controller objectDidBeginEditing:editor]);
    XCTAssert(controller.editorSet.count == 1);
    XCTAssertEqualObjects(controller.editorSet.anyObject, editor);
    [controller objectDidEndEditing:editor];
    XCTAssert(controller.editorSet.count == 0);
    XCTAssertNoThrow([controller objectDidEndEditing:editor]);
}

@end

//@property (readwrite) NSMutableSet<RNDEditor> *editorSet;
//@property (readwrite) NSMutableSet<NSString *> *declaredKeySet;
//@property (readwrite) NSMutableDictionary<NSString *, NSString *> *dependentKeyToModelKeyTable;
//@property (readwrite) NSMutableDictionary<NSString *, NSCountedSet<NSString *> *> *modelKeyToDependentKeyTable;
//@property (readwrite) NSMutableSet<NSString *> *modelKeysToRefreshEachTime;
//@property (readwrite) BOOL alwaysPresentsApplicationModalAlerts;
//@property (readwrite) BOOL refreshesAllModelKeys;
//@property (readwrite) BOOL multipleObservedModelObjects;
//@property (getter=isEditing, readwrite) BOOL editing;
//
//
//- (instancetype)init NS_DESIGNATED_INITIALIZER;
//- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
//
//- (void)objectDidBeginEditing:(id<RNDEditor>)editor;
//- (void)objectDidEndEditing:(id<RNDEditor>)editor;
//- (void)discardEditing;
//- (BOOL)commitEditing;
//- (void)commitEditingWithDelegate:(nullable id)delegate didCommitSelector:(nullable SEL)didCommitSelector contextInfo:(nullable void *)contextInfo;

