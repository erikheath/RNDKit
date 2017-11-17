//
//  RNDBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RNDBinderMode) {
    readOnlyMode,
    writeOnlyMode,
    readWriteMode
};

@class RNDBinding;
@class NSAttributeDescription;
@class RNDInvocationProcessor;

@protocol RNDBindableObject;

@interface RNDBinder : NSObject <NSCoding>

/** A system generated string identifier used to uniquely refer to an RNDBindings object. */
@property (strong, nonnull, readonly) NSString *binderIdentifier;



/** An array of RNDBinding objects that monitor, read from, and/or write to objects in the application. */
@property (nonnull, strong, readonly) NSMutableArray<RNDBinding *> *observedObjectbindings;

/** The RNDInvocationProcessors that may be executed once data collection, processing, and status evaluation have been completed for the binder's reverse data pipeline. */
@property (strong, nonnull, readonly) NSMutableArray<RNDInvocationProcessor *> *reverseObjectInvocations;


/** The to-one object within the one-to-many binding relationship. */
@property (weak, readwrite, nullable) NSObject<RNDBindableObject> *observer;

/** Indicates if the binder will monitor it */
@property (readonly) BOOL monitorsObserver;

/** The RNDInvocationProcessors that may be executed once data collection, processing, and status evaluation have been completed for the binder's forward data pipeline. */
@property (strong, nonnull, readonly) NSMutableArray<RNDInvocationProcessor *> *observerInvocations;


@property (strong, nullable, readonly) dispatch_queue_t syncQueue;

@property (strong, readwrite, nullable) id bindingObjectValue;
@property (readonly, getter=isBound) BOOL bound;

@property (strong, nullable, readonly) id nullPlaceholder;
@property (strong, nullable, readonly) id multipleSelectionPlaceholder;
@property (strong, nullable, readonly) id noSelectionPlaceholder;
@property (strong, nullable, readonly) id notApplicablePlaceholder;

- (instancetype _Nullable)init;
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder * _Nullable)aCoder;

- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error;

// These methods must be overrideen to do anything
- (void)updateValueOfObserverObject;
- (void)updateValueOfObservedObject;


@end
