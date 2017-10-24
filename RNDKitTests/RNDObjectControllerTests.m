//
//  RNDObjectControllerTests.m
//  RNDKitTests
//
//  Created by Erikheath Thomas on 10/18/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RNDKit/RNDKit.h>
#import <objc/runtime.h>
#import <CoreData/CoreData.h>

@interface RNDObjectControllerTests : XCTestCase

@property (readonly, nonnull) NSDictionary *collectionPropertiesDictionary;
@property (readonly, nonnull) NSArray *boolPropertiesArray;

@end

@implementation RNDObjectControllerTests

@synthesize collectionPropertiesDictionary = _collectionPropertiesDictionary;
@synthesize boolPropertiesArray = _boolPropertiesArray;

#pragma mark - Test Utilities

static NSString *classUnderTestName = @"Object Controller";

- (NSDictionary *)collectionPropertiesDictionary {
    if (_collectionPropertiesDictionary == nil) {
        _collectionPropertiesDictionary = @{@"content":@"NSMutableDictionary", @"editorSet":@"NSMutableSet", @"declaredKeySet":@"NSMutableSet", @"dependentKeyToModelKeyTable":@"NSMutableDictionary", @"modelKeyToDependentKeyTable":@"NSMutableDictionary", @"modelKeysToRefreshEachTime":@"NSMutableSet"};
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

- (void)testRNDObjectControllerCreationBasic {
    /////////////// Setup
    RNDObjectController *controller = [[RNDObjectController alloc] init];
    NSString *creationCondition = @"when created using alloc - init.";
    
    // Standards: Existence, Basic Configuration
    XCTAssertNotNil(controller, @"%@ should not be nil %@", classUnderTestName, creationCondition);
    XCTAssertNil(controller.content, @"%@ content property should be nil %@", classUnderTestName, creationCondition);
    controller.content = [[NSMutableDictionary alloc] init];
    [self object:controller collectionProperties:self.collectionPropertiesDictionary hasValidStateWithCount:0 forCondition:creationCondition];
    [self object:controller boolProperties:self.boolPropertiesArray hasValidStateWithExpectedValue:NO forCondition:creationCondition];
    XCTAssertTrue(controller.controllerType == RNDClassController, @"%@ should be class type %@", classUnderTestName, creationCondition);
}

- (void)testRNDObjectControllerCreationWithContent {
    /////////////// Setup initWithContent: mutable dictionary value
    NSMutableDictionary *contentDictionary = [NSMutableDictionary dictionaryWithDictionary: @{@"title":@"Content Dictionary Test", @"subTitle":@"Unit tests for RNDController Object"}];
    RNDObjectController *controller = [[RNDObjectController alloc] initWithContent:contentDictionary];
    NSString *creationCondition = @"when created using alloc - initWithContent and content is not nil.";
    
    // Standards: Existence, Basic Configuration
    XCTAssertNotNil(controller, @"%@ should not be nil %@", classUnderTestName, creationCondition);
    NSMutableDictionary *testDictionary = [NSMutableDictionary dictionaryWithDictionary:self.collectionPropertiesDictionary];
    [testDictionary removeObjectForKey:@"content"];
    [self object:controller collectionProperties:testDictionary hasValidStateWithCount:0 forCondition:creationCondition];
    [self object:controller collectionProperties:@{@"content":@"NSMutableDictionary"} hasValidStateWithCount:2 forCondition:creationCondition];
    [self object:controller boolProperties:self.boolPropertiesArray hasValidStateWithExpectedValue:NO forCondition:creationCondition];
    XCTAssertTrue(controller.controllerType == RNDClassController, @"%@ should be class type %@", classUnderTestName, creationCondition);
    
    /////////////// Setup: initWithContent: nil value
    controller = [[RNDObjectController alloc] initWithContent:nil];
    
    // Standards: Existence, Basic Configuration
    XCTAssertNotNil(controller, @"%@ should not be nil %@", classUnderTestName, creationCondition);
    XCTAssertNil(controller.content, @"%@ content property should be nil %@", classUnderTestName, creationCondition);
    [self object:controller collectionProperties:testDictionary hasValidStateWithCount:0 forCondition:creationCondition];
    [self object:controller boolProperties:self.boolPropertiesArray hasValidStateWithExpectedValue:NO forCondition:creationCondition];
    XCTAssertTrue(controller.controllerType == RNDClassController, @"%@ should be class type %@", classUnderTestName, creationCondition);
}

- (void)testRNDObjectControllerCreationFromCoder {
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
    NSString *creationCondition = @"when created using alloc - init.";
    
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

- (void)testContentCreationAndRemoval {
    /////////////// Setup
    RNDObjectController *controller = [[RNDObjectController alloc] init];
    NSString *creationCondition = @"when created using alloc - init.";
    
    id nilContentObject = controller.content;
    id newContentObject = [controller newObject];
    XCTAssertNil(nilContentObject);
    XCTAssertNotEqual(nilContentObject, newContentObject);
    
    controller.content = newContentObject;
    XCTAssertEqualObjects(newContentObject, controller.content);
    
    [controller addObject:nilContentObject];
    XCTAssertNil(controller.content);
    
    [controller add:nil];
    XCTAssertNotNil(controller.content);
    
    [controller removeObject:newContentObject];
    XCTAssertNotNil(controller.content);
    
    [controller remove: nil];
    XCTAssertNil(controller.content);
    
}

//- (void)prepareContent;
- (void)testPrepareContent {
    /////////////// Setup
    RNDObjectController *controller = [[RNDObjectController alloc] init];
    NSString *creationCondition = @"when created using alloc - init.";
    
    XCTAssertFalse(controller.automaticallyPreparesContent);
    controller.automaticallyPreparesContent = true;
    XCTAssertTrue(controller.automaticallyPreparesContent);
    
    XCTAssertNil(controller.content);
    [controller prepareContent];
    XCTAssertNotNil(controller.content);
    
    controller = [[RNDObjectController alloc] init];
    controller.automaticallyPreparesContent = true;
    [controller awakeFromNib];
    XCTAssertNotNil(controller.content);
    
}

@end
