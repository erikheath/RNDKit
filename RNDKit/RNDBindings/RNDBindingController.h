//
//  RNDBinderSet.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/27/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"

/*
 TODO: Figure this out
 
 
 The basic idea is:
 1. Return the requested archive to the sender if available.
 2. Get binder manifest if not already loaded
 3. Find the binding set with the VC ID.
 4. Load the set if not already loaded.
 5. Return the requested archive to the sender if available.
 
 Should the binder set class store the archives (loaded) and manifests? In the event of low memory, it should purge the archives which can be reconstituted on demand.
 
 When initialized at runtime, the class will load a default set. As there can be multiple manifest, each one is namespaced, as are all binding ids
 */

@interface RNDBindingController: NSObject <NSCoding>

@property(nullable, readwrite) NSString *binderSetIdentifier;
@property(nullable, readwrite) NSString *binderSetNamespace;
@property(nonnull, readonly) NSMutableDictionary<NSString *, RNDBinder *> *binders;

@property (strong, readonly, nonnull) NSMutableArray<NSString *> *protocolIdentifiers;

#pragma mark - Object Lifecycle
- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aCoder NS_DESIGNATED_INITIALIZER;

+ (instancetype _Nullable)unarchiveBinderSetAtURL:(NSURL * _Nonnull)url
                                            error:(NSError * __autoreleasing _Nullable * _Nullable)error;

+ (instancetype _Nullable)unarchiveBinderSetWithID:(NSString * _Nonnull)binderSetIdentifier
                                         namespace:(NSString * _Nullable)binderSetNamespace
                                             error:(NSError * __autoreleasing _Nullable * _Nullable)error;

+ (instancetype _Nullable)binderSetWithName:(NSString * _Nonnull)binderSetName;

- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

- (BOOL)archiveBinderSetToURL:(NSURL * _Nonnull)directory
                        error:(NSError * __autoreleasing _Nullable * _Nullable)error;

- (BOOL)archiveBinderSet:(NSError * __autoreleasing _Nullable * _Nullable)error;

#pragma mark - Editing Support
// While bindin controllers support many binders, they only support ONE binder designated as the editor value. All editing support provided by a binding controller is used in relation to the editorValue.

// Value Binder
@property (weak, readwrite, nullable) RNDBinder *editorValue;
@property (readwrite) BOOL registersAsEditor; // The controller uses the editor Value Binder to register as an editor for the data controller.

// Editor Registration Support
@property (weak, readwrite, nullable) RNDBinder *shouldBeginEditingEditorValue;
@property (weak, readwrite, nullable) RNDBinder *willBeginEditingEditorValue;
@property (weak, readwrite, nullable) RNDBinder *didBeginEditingEditorValue;
@property (weak, readwrite, nullable) RNDBinder *shouldEndEditingEditorValue;
@property (weak, readwrite, nullable) RNDBinder *willEndEditingEditorValue;
@property (weak, readwrite, nullable) RNDBinder *didEndEditingEditorValue;

// Triggers a call to associated Editor Registration binders
- (BOOL)editorShouldBeginEditingEditorValue:(id _Nullable)value;
- (void)editorWillBeginEditingEditorValue:(id _Nullable)value;
- (void)editorDidBeginEditingEditorValue:(id _Nullable)value;
- (BOOL)editorShouldEndEditingEditorValue:(id _Nullable)value;
- (void)editorWillEndEditingEditorValue:(id _Nullable)value;
- (void)editorDidEndEditingEditorValue:(id _Nullable)value;

// Value Update Support
@property (readwrite) BOOL validatesEditorValueUpdateImmediately; // The controller will use it's shouldUpdateEditorValue binder to validate any update to the editor value made during and editor session.
@property (readwrite) BOOL editorValueIsValid; // Observable enumeration
@property (strong, readwrite, nullable) NSError *editorValueValidationError; // Observable

@property (weak, readwrite, nullable) RNDBinder *shouldUpdateEditorValue;
@property (weak, readwrite, nullable) RNDBinder *willUpdateEditorValue;
@property (weak, readwrite, nullable) RNDBinder *didUpdateEditorValue;

- (BOOL)editorShouldUpdateEditorValue:(id _Nullable)value;
- (void)editorWillUpdateEditorValue:(id _Nullable)value;
- (void)editorDidUpdatedEditorValue:(id _Nullable)value;

// Value Replacement Support
@property (weak, readwrite, nullable) RNDBinder *shouldReplaceEditorValue; // When underlying data changes during an edit session. The binder calls set value for keypath on the controller (as the editor proxy).
@property (weak, readwrite, nullable) RNDBinder *willReplaceEditorValue; // When underlying data changes during an edit session. The binder calls set value for keypath on the controller (as the editor proxy).
@property (weak, readwrite, nullable) RNDBinder *didReplaceEditorValue; // When underlying data changes during an edit session. The binder calls set value for keypath on the controller (as the editor proxy).
@property (readwrite) BOOL editorValueLockingFailure; // Observable - An optimistic locking failure occurs when the should replace editor value returns no, preventing the editor from basing its edit on the datasource value.


- (BOOL)editorValue:(id _Nullable)editorValue shouldChangeToNewValue:(id _Nullable)newValue fromPriorValue:(id _Nullable)dataSourceValue; // If an optimistic locking failure has occurred where the current model value does not match the edited value, provides the binder with an opportunity to confirm that the change should occur.

// These are the methods that binders call on their binding controllers when specific key paths change. Set value for keypath is used to make the actual change as part of the updateBindingObjectValue method in a binder.
- (void)dataSourceWillReplaceBoundValue:(id _Nullable)value forKeyPath:(NSString * _Nonnull)keyPath; // Tells the controller that the value in the model will change while an edit in is progress.
- (void)dataSourceDidReplaceBoundValue:(id _Nullable)value forKeyPath:(NSString * _Nonnull)keyPath; // Tells the controller that the value in the model will change while an edit is in progress.

- (void)discardEditorValue; // Reverts to the current binding value and pushes it to the Editor(view).

- (BOOL)commitEditorValue; // Generally called by a mediating controller that has the binder registered as an editor.

- (void)commitEditorValueWithDelegate:(nullable id<RNDEditorDelegate>)delegate contextInfo:(nullable void *)contextInfo; // Generally called by an external actor that waits for an async result. For example, a save button that triggers a write to a remote database.

- (BOOL)commitEditorValueAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error; // Generally called by the object(editor) associated with the binder. Provide a way to automatically present an eror message.

@end

