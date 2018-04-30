//
//  RNDBinderSet.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/27/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"
#import "../RNDCoordinatedDictionary.h"
#import "../RNDCoordinatedArray.h"
#import "../RNDBindingProtocolsCategories/RNDEditor.h"

@interface RNDBindingController: NSObject <NSCoding, RNDBindingObject, RNDEditor> {
    @protected
    NSRecursiveLock * _coordinatorLock;
    dispatch_semaphore_t _syncCoordinator;
    BOOL _editing;
}

@property(readwrite, nullable) NSString *binderSetIdentifier;

@property(readwrite, nullable) NSString *binderSetNamespace;

@property (strong, readonly, nonnull) NSRecursiveLock *coordinatorLock;

@property(strong, readonly, nonnull) RNDCoordinatedDictionary<NSString *, RNDBinder *> *binders;

@property(weak, readwrite, nullable) id delegate;

- (NSError * _Nullable)setBinder:(RNDBinder * _Nonnull)binder
                          forBehavior:(NSString * _Nonnull)behavior
                    withSelectorString:(NSString * _Nullable)selectorString;

@property (strong, readonly, nonnull) RNDCoordinatedArray<NSString *> *protocolIdentifiers;

#pragma mark - Object Lifecycle
- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aCoder NS_DESIGNATED_INITIALIZER;

+ (instancetype _Nullable)unarchiveBinderSetAtURL:(NSURL * _Nonnull)url
                                            error:(NSError * __autoreleasing _Nullable * _Nullable)error;

+ (instancetype _Nullable)unarchiveBinderSetWithID:(NSString * _Nonnull)binderSetIdentifier
                                         namespace:(NSString * _Nullable)binderSetNamespace
                                             error:(NSError * __autoreleasing _Nullable * _Nullable)error;

- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

- (BOOL)archiveBinderSetToURL:(NSURL * _Nonnull)directory
                        error:(NSError * __autoreleasing _Nullable * _Nullable)error;

- (BOOL)archiveBinderSet:(NSError * __autoreleasing _Nullable * _Nullable)error;

#pragma mark - Proxy Update Support
- (void)updateValue:(id _Nullable)value atKeyPath:(NSString * _Nonnull)keyPath;
- (void)replaceValue:(id _Nullable)value atKeyPath:(NSString * _Nonnull)keyPath;


#pragma mark - Editing Support
// While binding controllers support many binders, they only support ONE binder designated as the editor value. All editing support provided by a binding controller is used in relation to the editorValue.

// Value Binder
@property (weak, readwrite, nullable) RNDBinder *valueBinder;
@property (readwrite) BOOL registersAsEditor; // The controller uses the editor Value Binder to register as an editor for the data controller.

#pragma mark - Editor Registration Support
@property (weak, readwrite, nullable) RNDBinder *shouldBeginEditBinder;
@property (weak, readwrite, nullable) RNDBinder *shouldEndEditBinder;

// Triggers a call to associated Editor Registration binders
- (BOOL)editorShouldBeginEditing;
- (void)editorWillBeginEditing;
- (void)editorDidBeginEditing;
- (BOOL)editorShouldEndEditing;
- (void)editorWillEndEditing;
- (void)editorDidEndEditing;

#pragma mark - Value Update Support
@property (readwrite) BOOL validatesEditorValueUpdateImmediately; // The controller will use it's shouldUpdateEditorValue binder to validate any update to the editor value made during and editor session.
@property (readwrite) BOOL editorValueIsValid; // Observable enumeration
@property (strong, readwrite, nullable) NSError *editorValueValidationError; // Observable

@property (weak, readwrite, nullable) RNDBinder *shouldUpdateEditorValue;

- (BOOL)editorShouldUpdateEditorValue;
- (void)editorWillUpdateEditorValue;
- (void)editorDidUpdatedEditorValue;

#pragma mark - Value Replacement Support

/*
 Value replacement decisioning happens when a controller (typically proxying for a view) is registered as an editor with one or more data sources and a change occurs in the underlying data presented by the data source(s). Typically, this situations occurs as a result of a data source mediating for a synchronized model, such as an iCloud Core Data or ubuiquitous document. When an underlying data change occurs, the following sequence of events transpires.
 
 1. If a binding controller is not registered as an editor, the standard value update support path is used by the controller to update any bound fields for its binding object.
 
 2. If a binding controller is registered as an editor, before the binder receives a KVO value change notification (binders only monitor changes that have completed), the data source will send the dataSourceWillReplaceBoundValue:atKeyPath message to the controller. Notice that there is no option for the controller to intercede in the value change. The reason for this is that a data source's responsibility is to reflect its state, which is driven by its model and any associated configuration, not a specific controller. This is different from the behavior of updates which, by means of editor registration, force the data source to reflect the controller, and therefore provide a means of synchronizing UI elements that are connected to the same data source. In effect, the behavior of the value replacement system enables a binding controller (and its corresponding binding object) to temporarily ignore any change in the underlying data source while registered as an editor. The result of this value change ignorance is that the editor value has supremacy over an underlying updates during an edit.
 
 The dataSourceWillReplaceBoundValue:atKeyPath message provides the controller with the opportunity to notify the user that a locking failure has occurred. By default the method is used to set the editorValueLockingFailure property to YES. This property can be observed and used to trigger the presentation of an alert dialog notifying the user that their data is out of sync. In addition, if a delegate has been set, it will receive the dataSourceWillReplaceBoundValue:atKeyPath:inEditor message.
 
 3. The data source will manage the underlying value change according to its merge / processing policy. For example, if an object controller is backed by a Core Data Managed Object, the Core Data Managed Object Context may or may not process any incoming changes depending on its configuration. For any messaging to the binding controller to occur, the data source must actually change the value at the registered key path.
 
 4. If the data changes, the processor associated with the key path will receive a change notification which will be passed to the value binder. The value binder processes its change normally, getting its binding value and calling the controller's updateValue:atKeyPath method with its updated bindingValue and associated key path. If the key path is the key path of the value binder (there are many properties that are bindable), the binding controller then sends itself an editorValue:shouldChangeToNewValue message.
 
 By default, the editorValue:shouldChangeToNewValue passes its arguments to the shouldReplaceEditorValue binder and returns the binder's bindingValue result. This binder can be used to create a processing tree that presents an alert to users, giving them the option to continue with their edit (i.e. returning NO) or to abandon the edit for the updated data (i.e. returning YES). If a delegate has implemented the method, it will be forwarded to the delegate, circumventing the shouldReplaceEditorValue binder if it has been set.
 
 5. If the current edited data should be abandoned for the updated data, the binding controller will proceed with its normal set-value for key path procedure. As part of that process, the binding controller will send its delegate an editorWillReplaceEditorValue message, will then set the value, and finally will send the editorDidReplaceEditorValue message to the delegate. The delegate messages give the app the ability to extend the value setting workflow as needed before and after the change in value.
 
 6. Setting the data completes the update process. Note that replacing the value does not, by default, unregister the editor. Value replacement and editing are independent processes. This is useful for a number of tasks such as collaborative text editing. At this point, the locking failure has been corrected, and after the set-value process, the editorValueLockingFailure property will be set to NO to indicate that the failure has been resolved.
 
 If user or app chooses to keep the editor's version of the updated data, the editorValueLockingFailure property will remain set to YES until the editor's value is written to the data source. This will effectively overwrite the updated data. Once that write happens, the editor's value will be resynchronized with the data source, removing the locking failure.
 
 7. At some point during the value change, or possibly at the end, the binding controller will receive the dataSourceDidReplaceBoundValue:atKeyPath message from the data source. By default, this message is transformed into a message to the binding controller's delegate - dataSourceDidReplaceBoundValue:atKeyPath:inEditor.
 
 */

@property (weak, readwrite, nullable) RNDBinder *shouldReplaceEditorValue; // When underlying data changes during an edit session. The binder calls set value for keypath on the controller (as the editor proxy).
@property (readwrite) BOOL editorValueLockingFailure; // Observable - An optimistic locking failure occurs when the should replace editor value returns no, preventing the editor from basing its edit on the datasource value.


- (BOOL)editorValue:(id _Nonnull)editorValue shouldChangeToNewValue:(id _Nonnull)newValue; // If an optimistic locking failure has occurred where the current model value does not match the edited value, provides the binder with an opportunity to confirm that the change should occur. May also be implemented as a delegate method.

- (void)editorWillReplaceEditorValue:(id<RNDEditor> _Nonnull)editor; // Delegate method

- (void)editorDidReplaceEditorValue:(id<RNDEditor> _Nonnull)editor; // Delegate method

// These are the methods that binders call on their binding controllers when specific key paths change. Set value for keypath is used to make the actual change as part of the updateBindingObjectValue method in a binder.
- (void)dataSourceWillReplaceBoundValue:(id _Nullable)value
                             atKeyPath:(NSString * _Nonnull)keyPath; // Tells the controller that the value in the model will change while an edit in is progress.
- (void)dataSourceDidReplaceBoundValue:(id _Nullable)value
                            atKeyPath:(NSString * _Nonnull)keyPath; // Tells the controller that the value in the model will change while an edit is in progress.
#pragma mark - RNDEditor

/*
 The discardEditorValue method forces the editor to discard its edited contents and revert to the value in the bound data source. To accomplish this, the method triggers an update by calling the replaceValue:atKeyPath method with the value of value binder. This method should only be called when the binding controller is registered as an editor for the data source. Calling discardEditorValue will not deregister the binding controller as an editor.
 
 This method is typically called when an app / user wants to reset a field they are currently editing.
 */
- (void)discardEditorValue;

/*
 The commitEditorValue method forces the editor to write its current value to the data source. In the event of an error, for example, a validation error, the method returns NO. The commitEditorValue calls the updateObservedObjectValue method of the value binder and returns the result of that method call. This method is generally called by a mediating controller that has the binding controller registered as an editor.
 */
- (BOOL)commitEditorValue;

/*
 The commitEditorValueWithDelegate:contextInfo: method forces the editor to write its current value to the data source. The commitEditorValueWithDelegate:contextInfo: method calls the updateObservedObjectValue method of the value binder. Regardless of the outcome, this method sends the delegate the result, the context, and an optional error using the following method:
 
    - (void)editor:(id)editor didCommit:(BOOL)didCommit contextInfo:(void *)contextInfo error:(NSError *)error;
 
 

 */
- (void)commitEditorValueWithDelegate:(nullable id<RNDEditorDelegate>)delegate
                          contextInfo:(nullable void *)contextInfo; // Generally called by an external actor that waits for an async result. For example, a save button that triggers a write to a remote database.

- (BOOL)commitEditorValueAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error; // Generally called by the object(editor) associated with the binder. Provide a way to automatically present an eror message. Can be set as the behavior when an editor stops editing or whenever an editor posts a change.
// TODO: Needs a commits edits property.
// TODO: Maybe needs a reset on error property.

@end

