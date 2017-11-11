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

@protocol RNDBindableObject;

@interface RNDBinder : NSObject <NSCoding>

@property (strong, nonnull, readonly) NSString *binderIdentifier;
@property (nonnull, strong, readonly) NSArray<RNDBinding *> *bindings;
@property (weak, readwrite, nullable) NSObject<RNDBindableObject> *observer;
@property (strong, nonnull, readonly) NSString *observerKey;
@property (readonly) RNDBinderMode binderMode;
@property (readonly) BOOL monitorsObservable;
@property (readonly) BOOL monitorsObserver;
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
