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


@class RNDBindingProcessor;

@protocol RNDBindableObject;

@interface RNDBinder : NSObject <NSCoding, RNDEditor>

@property (strong, nullable, readonly) dispatch_queue_t coordinator;
@property (nonnull, strong, readonly) dispatch_semaphore_t syncCoordinator;

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
- (BOOL)updateObservedObjectValue:(NSError * __autoreleasing _Nullable * _Nullable)error;

#pragma mark - Editor Management
@property BOOL requiresConfirmationOnLockingFailure;
@property BOOL registersAsEditor;
@property BOOL validatesImmediately;
@property BOOL editedValueIsValid; // Observable
@property (strong, readwrite, nullable) NSError *editedValueError; // Observable

- (void)editorDidBeginEditingBoundValue:(id _Nullable)value; // Editor (view) notifies binder of a pending value change.
- (void)editorDidEndEditingBoundValue:(id _Nullable)value; // Editor (view) notifies binder that a value change happened.

- (void)dataSourceWillChangeEditedValue:(id _Nullable)value forKeyPath:(NSString * _Nonnull)keyPath; // Tells the editor that the value in the model will change while an edit in is progress.
- (void)dataSourceDidChangeEditedValue:(id _Nullable)value forKeyPath:(NSString * _Nonnull)keyPath; // Tells the editor that the value in the model will change while an edit is in progress.

- (BOOL)editedValue:(id _Nullable)editedValue shouldChangeToValue:(id _Nullable)newValue fromDataSourceValue:(id _Nullable)dataSourceValue; // If an optimistic locking failure has occurred where the current model value does not match the edited value, provides the binder with an opportunity to confirm that the change should occur.

- (void)discardBoundEdit; // Reverts to the current binding value and pushes it to the Editor(view).

- (BOOL)commitBoundEdit; // Generally called by a mediating controller that has the binder registered as an editor.

- (void)commitBoundEditWithDelegate:(nullable id<RNDEditorDelegate>)delegate contextInfo:(nullable void *)contextInfo; // Generally called by an external actor that waits for an async result. For example, a save button that triggers a write to a remote database.

- (BOOL)commitBoundEditAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error; // Generally called by the object(editor) associated with the binder. Provide a way to automatically present an eror message.

@end
