//
//  NSObject+RNDObjectBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/21/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingConstants.h"
#import "RNDBindingProtocols/RNDEditor.h"

@class RNDBinder;

@protocol RNDBindableObject <NSObject>

@property (strong, readwrite, nullable) NSString *bindingIdentifier;
@property (strong, readwrite, nullable) IBOutletCollection(id) NSArray * bindingDestinations;
@property (strong, readwrite, nullable) id bindingObjectValue;
@property (readonly) BOOL valueAsBool;
@property (readonly) NSInteger valueAsInteger;
@property (readonly) long valueAsLong;
@property (readonly) float valueAsFloat;
@property (readonly) double valueAsDouble;
@property (readonly, nullable) NSString * valueAsString;
@property (readonly, nullable) NSDate * valueAsDate;
@property (readonly, nullable) NSUUID * valueAsUUID;
@property (readonly, nullable) NSData * valueAsData;
@property (readonly, nullable) id valueAsObject;

@end

@interface NSObject (RNDBindableObject) <RNDBindableObject, RNDEditor>

#pragma mark - Properties
@property (strong, readonly, nonnull) NSDictionary<RNDBinderName, RNDBinder *> *binders;
@property (strong, readwrite, nullable) NSString *bindingIdentifier;
@property (strong, readonly, nonnull) dispatch_queue_t syncQueue;
@property (strong, readwrite, nullable) IBOutletCollection(id) NSArray * bindingDestinations;
@property (strong, readwrite, nullable) id bindingObjectValue;
@property (readonly) BOOL valueAsBool;
@property (readonly) NSInteger valueAsInteger;
@property (readonly) long valueAsLong;
@property (readonly) float valueAsFloat;
@property (readonly) double valueAsDouble;
@property (readonly, nullable) NSString * valueAsString;
@property (readonly, nullable) NSDate * valueAsDate;
@property (readonly, nullable) NSUUID * valueAsUUID;
@property (readonly, nullable) NSData * valueAsData;
@property (readonly, nullable) id valueAsObject;


#pragma mark - Object Lifecycle
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aDecoder;
- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

#pragma mark - Binding Management
- (BOOL)connectAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)disconnectAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
