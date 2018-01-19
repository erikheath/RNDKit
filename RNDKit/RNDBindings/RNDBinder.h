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

@class RNDBindingProcessor;

@protocol RNDBindableObject;

@interface RNDBinder : NSObject <NSCoding, RNDEditor, RNDBindingObject>

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
@property (readwrite) BOOL requiresConfirmationOnLockingFailure;
@property (readwrite) BOOL registersAsEditor;
@property (readwrite) BOOL validatesImmediately;
@property (readwrite) BOOL bindingObjectValueIsValid; // Observable
@property (strong, readwrite, nullable) NSError *bindingObjectValueValidationError; // Observable

- (BOOL)updateObservedObjectValue:(NSError * __autoreleasing _Nullable * _Nullable)error;

// These are the methods that editors (views) should call on their binders when changes occur? Or, these are the methods that a binder implements when it is observing changes in a view.
- (void)editorDidBeginEditingBoundValue:(id _Nullable)value; // Editor (view) notifies binder of a pending value change.
- (void)editorDidEndEditingBoundValue:(id _Nullable)value; // Editor (view) notifies binder that a value change happened.

// These are the methods that datasources should call on their editors when specific key paths change.
- (void)dataSourceWillChangeEditedValue:(id _Nullable)value forKeyPath:(NSString * _Nonnull)keyPath; // Tells the editor that the value in the model will change while an edit in is progress.
- (void)dataSourceDidChangeEditedValue:(id _Nullable)value forKeyPath:(NSString * _Nonnull)keyPath; // Tells the editor that the value in the model will change while an edit is in progress.

// This is the method that a binder will call on a delegate or itself to determine how to behave in this situation. This is particularly useful when commitBoundEditWithDelegate is called because the delegate can intervene and determine the outcome.
- (BOOL)editedValue:(id _Nullable)editedValue shouldChangeToValue:(id _Nullable)newValue fromDataSourceValue:(id _Nullable)dataSourceValue; // If an optimistic locking failure has occurred where the current model value does not match the edited value, provides the binder with an opportunity to confirm that the change should occur.

- (void)discardBoundEdit; // Reverts to the current binding value and pushes it to the Editor(view).

- (BOOL)commitBoundEdit; // Generally called by a mediating controller that has the binder registered as an editor.

- (void)commitBoundEditWithDelegate:(nullable id<RNDEditorDelegate>)delegate contextInfo:(nullable void *)contextInfo; // Generally called by an external actor that waits for an async result. For example, a save button that triggers a write to a remote database.

- (BOOL)commitBoundEditAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error; // Generally called by the object(editor) associated with the binder. Provide a way to automatically present an eror message.

@end
