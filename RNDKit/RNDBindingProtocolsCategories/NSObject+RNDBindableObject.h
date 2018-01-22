//
//  NSObject+RNDObjectBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/21/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingConstants.h"
#import "RNDBindableObject.h"

@class RNDBinderSet;

@interface NSObject (RNDBindableObject) <RNDBindableObject>

#pragma mark - Properties
@property (strong, readwrite, nullable) NSString *bindingIdentifier;
@property (strong, readonly, nullable) NSMutableArray * bindingDestinations;
@property (strong, readonly, nullable) RNDBindingController *bindings;

#pragma mark - Object Lifecycle
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aDecoder;
- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

#pragma mark - Binding Management
- (BOOL)connectAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)disconnectAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
