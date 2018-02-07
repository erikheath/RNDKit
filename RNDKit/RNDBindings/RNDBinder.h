//
//  RNDBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../RNDBindingProtocolsCategories/RNDEditorRegistration.h"
#import "../RNDBindingProtocolsCategories/RNDEditorDelegate.h"
#import "../RNDBindingProtocolsCategories/RNDBindingObject.h"
#import "../RNDBindingProtocolsCategories/RNDBindingObjectValue.h"

@class RNDBindingProcessor;

@protocol RNDBindableObject;

@interface RNDBinder : NSObject <NSCoding, RNDEditor, RNDBindingObject, RNDBindingObjectValue>

@property (strong, nullable, readonly) dispatch_queue_t coordinator;
@property (nonnull, strong, readonly) dispatch_semaphore_t syncCoordinator;

@property (strong, nonnull, readwrite) NSString *bindingName;

#pragma mark - Binding Object
@property (weak, readwrite, nullable) NSObject<RNDBindableObject> *bindingObject;
@property (strong, nonnull, readwrite) NSString *bindingObjectKeyPath;
@property (readwrite) BOOL monitorsBindingObject;
- (void)bindingObjectValueNeedsUpdate; // Called when a change occurs in one of the processors that should trigger synchronization.
- (id _Nullable)updateBindingObjectValue;
- (void)updateCoordinatedBindingObjectValue:(id _Nullable)coordinatedValue;

#pragma mark - Processors
@property (strong, nullable, readwrite) RNDBindingProcessor *inflowProcessor;
@property (strong, nullable, readonly) NSMutableArray<RNDBindingProcessor *> *outflowProcessors;
@property (strong, nullable, readonly) NSArray<RNDBindingProcessor *> *boundOutflowProcessors;

#pragma mark - Object Lifecycle
- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder * _Nullable)aCoder;

#pragma mark - Editor Management
// TODO: Add this
//The binder needs to notify the controller that there was a write validation error. There needs to be a method(s) for this - it basically goes validate, write/no write. For the validation, it should be passed to the controller and the error set. Since a binder doesn't technically have a value - it can't really error.

- (BOOL)updateObservedObjectValue:(NSError * __autoreleasing _Nullable * _Nullable)error;


@end
