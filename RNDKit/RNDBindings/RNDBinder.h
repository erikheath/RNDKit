//
//  RNDBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RNDBindingProcessor;

@protocol RNDBindableObject;

@interface RNDBinder : NSObject <NSCoding>

@property (strong, nullable, readonly) dispatch_queue_t syncQueue;

#pragma mark - Binding Object
@property (strong, nonnull, readwrite) NSString *bindingName;
@property (weak, readwrite, nullable) NSObject<RNDBindableObject> *bindingObject;
@property (strong, nonnull, readwrite) NSString *bindingObjectKeyPath;
@property (readwrite) BOOL monitorsBindingObject;

#pragma mark - Processors
@property (strong, nullable, readwrite) RNDBindingProcessor *inflowProcessor;
@property (strong, nullable, readonly) NSMutableArray<RNDBindingProcessor *> *outflowProcessors;
@property (strong, nullable, readonly) NSArray<RNDBindingProcessor *> *boundOutflowProcessors;

#pragma mark - Object Lifecycle
- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder * _Nullable)aCoder;

#pragma mark - Binding Management
@property (readonly, getter=isBound) BOOL bound;

- (void)bind;
- (void)unbind;
- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (BOOL)bindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;
- (BOOL)unbindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;

#pragma mark - Value Management
@property (strong, readonly, nullable) id bindingValue;

- (id _Nullable)coordinatedBindingValue;
- (id _Nullable)rawBindingValue;
- (id _Nullable)calculatedBindingValue:(id _Nullable)bindingValue;
- (id _Nullable)filteredBindingValue:(id _Nullable)bindingValue;
- (id _Nullable)transformedBindingValue:(id _Nullable)bindingValue;
- (id _Nullable)wrappedBindingValue:(id _Nullable)bindingValue;

- (void)updateBindingObjectValue;
- (void)updateObservedObjectValue;


@end
