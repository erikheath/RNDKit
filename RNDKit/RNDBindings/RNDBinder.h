//
//  RNDBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RNDBinderMode) {
    valueOnlyMode,
    keyedValueMode,
    orderedKeyedValueMode
};

@class RNDBinding;
@class RNDPatternedBinding;
@class RNDPredicateBinding;

@protocol RNDBindableObject;

/**
 The RNDBinder enables reading, writing, or read/write connections between an object acting as a model and an object acting as an observer/editor.
 
 In readOnlyMode and readOnlyMonitorMode, the binder maintains one binding object that connects to and optionally monitors a model object that conforms to RNDObservable, typically a subclass of RNDController. On request, or when a change is detected in the model object, the binder object will request the current value of its binding object and write that value, after optionally transforming it with its value transformer, to the property of its observer object specified by the binder's observerKey property.
 
 In writeOnly mode, the binder maintains one binding object that connects to a model object that conforms to RNDObservable, typically a subclass of RNDController. On request, or when a change is detected in the editor object, the binder will set the new value on the model object via its binding object after optionally reverse transforming it with its value transformer.
 
 In readWrite mode, the binder maintains one binding object that connects to a model object that conforms to RNDObservable, typically a subclass of RNDController. In this mode the binder and its binding automatically synchronize the values of the model and the observer/editor.
 */
@interface RNDBinder : NSObject <NSCoding>

@property (strong, nonnull, readonly) NSString *binderIdentifier;
@property (nonnull, strong, readonly) NSArray<RNDBinding *> *inflowBindings;
@property (nonnull, strong, readonly) NSArray<RNDBinding *> *outflowBindings;
@property (weak, readwrite, nullable) NSObject<RNDBindableObject> *observer;
@property (strong, nonnull, readonly) NSString *observerKey;
@property (readonly) RNDBinderMode binderMode;
@property (readonly) BOOL monitorsObserver;
@property (strong, nullable, readonly) dispatch_queue_t syncQueue;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@property (strong, readwrite, nullable) id bindingObjectValue;
@property (readonly, getter=isBound) BOOL bound;

@property (strong, nullable, readonly) RNDBinding *nullPlaceholder;
@property (strong, nullable, readonly) RNDBinding *multipleSelectionPlaceholder;
@property (strong, nullable, readonly) RNDBinding *noSelectionPlaceholder;
@property (strong, nullable, readonly) RNDBinding *notApplicablePlaceholder;
@property (strong, nullable, readonly) RNDBinding *nilPlaceholder;

@property (readonly) BOOL filtersNilValues;
@property (readonly) BOOL filtersMarkerValues;
@property (readonly) BOOL unwrapSingleValue;
@property (readonly) BOOL mutuallyExclusive;


- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder * _Nullable)aCoder;

- (void)bind;
- (void)unbind;

- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (BOOL)bindObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;
- (BOOL)unbindObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;


// These methods must be overrideen to do anything
- (void)updateValueOfObserverObject;
- (void)updateValueOfObservedObject;


@end
