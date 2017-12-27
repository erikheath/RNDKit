//
//  RNDBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RNDBindingProcessor;
@class RNDPatternedStringProcessor;
@class RNDPredicateProcessor;

@protocol RNDBindableObject;

/**
 The RNDBinder enables reading, writing, or read/write connections between an object acting as a model and an object acting as an observer/editor.
 
 In readOnlyMode and readOnlyMonitorMode, the binder maintains one binding object that connects to and optionally monitors a model object that conforms to RNDObservable, typically a subclass of RNDController. On request, or when a change is detected in the model object, the binder object will request the current value of its binding object and write that value, after optionally transforming it with its value transformer, to the property of its observer object specified by the binder's observerKey property.
 
 In writeOnly mode, the binder maintains one binding object that connects to a model object that conforms to RNDObservable, typically a subclass of RNDController. On request, or when a change is detected in the editor object, the binder will set the new value on the model object via its binding object after optionally reverse transforming it with its value transformer.
 
 In readWrite mode, the binder maintains one binding object that connects to a model object that conforms to RNDObservable, typically a subclass of RNDController. In this mode the binder and its binding automatically synchronize the values of the model and the observer/editor.
 */
@interface RNDBinder : NSObject <NSCoding>

@property (strong, nonnull, readwrite) NSString *bindingName;
@property (weak, readwrite, nullable) NSObject<RNDBindableObject> *boundObject;
@property (strong, nonnull, readwrite) NSString *boundObjectKey;
@property (readwrite) BOOL monitorsBoundObject;
@property (strong, nullable, readonly) dispatch_queue_t syncQueue;
@property (strong, nullable, readwrite) RNDBindingProcessor *inflowProcessor;
@property (strong, nullable, readwrite) RNDBindingProcessor *outflowProcessor;

@property (strong, readwrite, nullable) id bindingValue;
@property (readonly, getter=isBound) BOOL bound;


- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder * _Nullable)aCoder;

- (void)bind;
- (void)unbind;
- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (BOOL)bindObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;
- (BOOL)unbindObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;
- (id _Nullable)bindingObjectValue;
- (void)setBindingObjectValue:(id _Nullable)bindingObjectValue;

// These methods must be overrideen to do anything
- (void)updateBindingObjectValue;
- (void)updateValueOfObservedObject;


@end
