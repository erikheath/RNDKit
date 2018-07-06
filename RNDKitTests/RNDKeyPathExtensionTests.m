//
//  RNDKeyPathExtensionTests.m
//  RNDKitTests
//
//  Created by Erikheath Thomas on 6/13/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <RNDKit/RNDKit.h>

@interface RNDKeyPathExtensionTests : XCTestCase

@end

@implementation RNDKeyPathExtensionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
//    initializeValuePathExtensions();
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    initializeValuePathExtensions();
    [super tearDown];
}

- (void)testBasicValuePath {
    NSDictionary *basicDictionary = @{@"my":@{@"internal":@{@"secret":@(0)}}, @"key":@(1)};
    NSNumber *internalNumber = [basicDictionary valueForExtendedKeyPath:@"my.internal.secret.@filter(SELF < 5)"];
    XCTAssertEqualObjects(internalNumber, @(0));
    
    id array = [NSMutableArray arrayWithCapacity:100];
    for (NSUInteger counter = 0; counter < 100; counter++) {
        [array addObject:@(counter)];
    }
    id arrayArray = [NSMutableArray arrayWithCapacity:100];
    for (NSNumber *count in array) {
        [arrayArray addObject:array];
    }
    array = [NSArray arrayWithArray:array];
    NSDictionary *arrayDictionary = @{@"array":array};
    NSDictionary *dictionary = @{@"dictionary":arrayDictionary};
    NSMutableDictionary *passingObjects = [dictionary valueForExtendedKeyPath:@"dictionary.array.@map(@filter(SELF < 20)).@combine(NSMutableDictionary, first:@index(1), second:@index(2))"];
//    XCTAssert([passingObjects count]  == 20);
//    XCTAssert([[passingObjects valueForExtendedKeyPath:@"@avg()"] doubleValue] == 9.5);
    XCTAssert([passingObjects count] == 2);

//    NSNumber *sum = [arrayArray valueForExtendedKeyPath:@"@sum(SELF.@sum(SELF.@avg(SELF.@filter(SELF < 20))))"];
}

@end
