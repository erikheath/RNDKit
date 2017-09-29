//
//  RNDBindings.h
//  RNDBindableObjects
//
//  Created by Erikheath Thomas on 6/29/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

//extern id RNDMultipleValuesMarker;
//extern id RNDNoSelectionMarker;
//extern id RNDNotApplicableMarker;

extern BOOL RNDIsControllerMarker(__nullable id object);

typedef NSString * RNDBindingName NS_EXTENSIBLE_STRING_ENUM;
typedef NSString * RNDBindingOption NS_STRING_ENUM;

// keys for the returned dictionary of -infoForBinding:
//typedef NSString * RNDBindingInfoKey NS_STRING_ENUM;
//extern RNDBindingInfoKey RNDObservedObjectKey;
//extern RNDBindingInfoKey RNDObservedKeyPathKey;
//extern RNDBindingInfoKey RNDOptionsKey;

@protocol RNDKeyValueBindingCreation <NSObject>

+ (void)exposeBinding:(RNDBindingName)binding;    // bindings specified here will be exposed automatically in -exposedBindings (unless implementations explicitly filter them out, for example in subclasses)
@property (readonly, copy) NSArray<RNDBindingName> *exposedBindings;   // for a new key exposed through this method, the default implementation simply falls back to key-value coding
- (nullable Class)valueClassForBinding:(RNDBindingName)binding;    // optional - mostly for matching transformers

/* Bindings are considered to be a property of the object which is bound (the object the following two methods are sent to) and all information related to bindings should be retained by the object; all standard bindings on AppKit objects (views, cells, table columns, controllers) unbind their bindings automatically when they are released, but if you create key-value bindings for other kind of objects, you need to make sure that you remove those bindings when you release them (observed objects don't retain their observers, so controllers/model objects might continue referencing and messaging the objects that was bound to them).
 */
- (void)bind:(RNDBindingName)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(nullable NSDictionary<RNDBindingOption, id> *)options;    // placeholders and value transformers are specified in options dictionary
- (void)unbind:(RNDBindingName)binding;

/* Returns a dictionary with information about a binding or nil if the binding is not bound (this is mostly for use by subclasses which want to analyze the existing bindings of an object) - the dictionary contains three key/value pairs: RNDObservedObjectKey: object bound, RNDObservedKeyPathKey: key path bound, RNDOptionsKey: dictionary with the options and their values for the bindings.
 */
- (nullable NSDictionary<RNDBindingInfoKey, id> *)infoForBinding:(RNDBindingName)binding;

/* Returns an array of NSAttributeDescriptions that describe the options for aBinding. The descriptions are used by Interface Builder to build the options editor UI of the bindings inspector. Each binding may have multiple options. The options and attribute descriptions have 3 properties in common:
 
 - The option "name" is derived from the attribute description name.
 
 - The type of UI built for the option is based on the attribute type.
 
 - The default value shown in the options editor comes from the attribute description's defaultValue.*/


- (NSArray<NSAttributeDescription *> *)optionDescriptionsForBinding:(RNDBindingName)binding;


@end

@protocol RNDPlaceholders

+ (void)setDefaultPlaceholder:(nullable id)placeholder forMarker:(nullable id)marker withBinding:(RNDBindingName)binding;    // marker can be nil or one of RNDMultipleValuesMarker, RNDNoSelectionMarker, RNDNotApplicableMarker
+ (nullable id)defaultPlaceholderForMarker:(nullable id)marker withBinding:(RNDBindingName)binding;    // marker can be nil or one of RNDMultipleValuesMarker, RNDNoSelectionMarker, RNDNotApplicableMarker

@end

// methods implemented by controllers, CoreData's managed object contexts (and potentially documents)
@protocol RNDEditorRegistration

- (void)objectDidBeginEditing:(id)editor;
- (void)objectDidEndEditing:(id)editor;

@end

// methods implemented by controllers, CoreData's managed object contexts, and user interface elements
@protocol RNDEditor

- (void)discardEditing;    // forces changing to end (reverts back to the original value)
- (BOOL)commitEditing;    // returns whether end editing was successful (while trying to apply changes to a model object, there might be validation problems or so that prevent the operation from being successful


/* Given that the receiver has been registered with -objectDidBeginEditing: as the editor of some object, and not yet deregistered by a subsequent invocation of -objectDidEndEditing:, attempt to commit the result of the editing. When committing has either succeeded or failed, send the selected message to the specified object with the context info as the last parameter. The method selected by didCommitSelector must have the same signature as:
 
 - (void)editor:(id)editor didCommit:(BOOL)didCommit contextInfo:(void *)contextInfo;
 
 If an error occurs while attempting to commit, because key-value coding validation fails for example, an implementation of this method should typically send the NSView in which editing is being done a -presentError:modalForWindow:delegate:didRecoverSelector:contextInfo: message, specifying the view's containing window.
 */
- (void)commitEditingWithDelegate:(nullable id)delegate didCommitSelector:(nullable SEL)didCommitSelector contextInfo:(nullable void *)contextInfo;


/* During autosaving, commit editing may fail, due to a pending edit.  Rather than interrupt the user with an unexpected alert, this method provides the caller with the option to either present the error or fail silently, leaving the pending edit in place and the user's editing uninterrupted.  This method attempts to commit editing, but if there is a failure the error is returned to the caller to be presented or ignored as appropriate.  If an error occurs while attempting to commit, an implementation of this method should return NO as well as the generated error by reference.  Returns YES if commit is successful.
 
 If you have enabled autosaving in your application, and your application has custom objects that implement or override the NSEditor protocol, you must also implement this method in those NSEditors.
 */
- (BOOL)commitEditingAndReturnError:(NSError **)error;

@end

// constants for binding names
//extern RNDBindingName NSAlignmentBinding;
//extern RNDBindingName NSAlternateImageBinding;
//extern RNDBindingName NSAlternateTitleBinding;
//extern RNDBindingName NSAnimateBinding;
//extern RNDBindingName NSAnimationDelayBinding;
//extern RNDBindingName NSArgumentBinding;
//extern RNDBindingName NSAttributedStringBinding;
//extern RNDBindingName NSContentArrayBinding;
//extern RNDBindingName NSContentArrayForMultipleSelectionBinding;
//extern RNDBindingName NSContentBinding;
//extern RNDBindingName NSContentDictionaryBinding;
//extern RNDBindingName NSContentHeightBinding;
//extern RNDBindingName NSContentObjectBinding;
//extern RNDBindingName NSContentObjectsBinding;
//extern RNDBindingName NSContentSetBinding;
//extern RNDBindingName NSContentValuesBinding;
//extern RNDBindingName NSContentWidthBinding;
//extern RNDBindingName NSCriticalValueBinding;
//extern RNDBindingName NSDataBinding;
//extern RNDBindingName NSDisplayPatternTitleBinding;
//extern RNDBindingName NSDisplayPatternValueBinding;
//extern RNDBindingName NSDocumentEditedBinding;
//extern RNDBindingName NSDoubleClickArgumentBinding;
//extern RNDBindingName NSDoubleClickTargetBinding;
//extern RNDBindingName NSEditableBinding;
//extern RNDBindingName NSEnabledBinding;
//extern RNDBindingName NSExcludedKeysBinding;
//extern RNDBindingName NSFilterPredicateBinding;
//extern RNDBindingName NSFontBinding;
//extern RNDBindingName NSFontBoldBinding;
//extern RNDBindingName NSFontFamilyNameBinding;
//extern RNDBindingName NSFontItalicBinding;
//extern RNDBindingName NSFontNameBinding;
//extern RNDBindingName NSFontSizeBinding;
//extern RNDBindingName NSHeaderTitleBinding;
//extern RNDBindingName NSHiddenBinding;
//extern RNDBindingName NSImageBinding;
//extern RNDBindingName NSIncludedKeysBinding;
//extern RNDBindingName NSInitialKeyBinding;
//extern RNDBindingName NSInitialValueBinding;
//extern RNDBindingName NSIsIndeterminateBinding;
//extern RNDBindingName NSLabelBinding;
//extern RNDBindingName NSLocalizedKeyDictionaryBinding;
//extern RNDBindingName NSManagedObjectContextBinding;
//extern RNDBindingName NSMaximumRecentsBinding;
//extern RNDBindingName NSMaxValueBinding;
//extern RNDBindingName NSMaxWidthBinding;
//extern RNDBindingName NSMinValueBinding;
//extern RNDBindingName NSMinWidthBinding;
//extern RNDBindingName NSMixedStateImageBinding;
//extern RNDBindingName NSOffStateImageBinding;
//extern RNDBindingName NSOnStateImageBinding;
//extern RNDBindingName NSPositioningRectBinding;
//extern RNDBindingName NSPredicateBinding;
//extern RNDBindingName NSRecentSearchesBinding;
//extern RNDBindingName NSRepresentedFilenameBinding;
//extern RNDBindingName NSRowHeightBinding;
//extern RNDBindingName NSSelectedIdentifierBinding;
//extern RNDBindingName NSSelectedIndexBinding;
//extern RNDBindingName NSSelectedLabelBinding;
//extern RNDBindingName NSSelectedObjectBinding;
//extern RNDBindingName NSSelectedObjectsBinding;
//extern RNDBindingName NSSelectedTagBinding;
//extern RNDBindingName NSSelectedValueBinding;
//extern RNDBindingName NSSelectedValuesBinding;
//extern RNDBindingName NSSelectionIndexesBinding;
//extern RNDBindingName NSSelectionIndexPathsBinding;
//extern RNDBindingName NSSortDescriptorsBinding;
//extern RNDBindingName NSTargetBinding;
//extern RNDBindingName NSTextColorBinding;
//extern RNDBindingName NSTitleBinding;
//extern RNDBindingName NSToolTipBinding;
//extern RNDBindingName NSTransparentBinding;
//extern RNDBindingName NSValueBinding;
//extern RNDBindingName NSValuePathBinding;
//extern RNDBindingName NSValueURLBinding;
//extern RNDBindingName NSVisibleBinding;
//extern RNDBindingName NSWarningValueBinding;
//extern RNDBindingName NSWidthBinding;

// constants for binding options
//extern RNDBindingOption NSAllowsEditingMultipleValuesSelectionBindingOption;
//extern RNDBindingOption NSAllowsNullArgumentBindingOption;
//extern RNDBindingOption NSAlwaysPresentsApplicationModalAlertsBindingOption;
//extern RNDBindingOption NSConditionallySetsEditableBindingOption;
//extern RNDBindingOption NSConditionallySetsEnabledBindingOption;
//extern RNDBindingOption NSConditionallySetsHiddenBindingOption;
//extern RNDBindingOption NSContinuouslyUpdatesValueBindingOption;
//extern RNDBindingOption NSCreatesSortDescriptorBindingOption;
//extern RNDBindingOption NSDeletesObjectsOnRemoveBindingsOption;
//extern RNDBindingOption NSDisplayNameBindingOption;
//extern RNDBindingOption NSDisplayPatternBindingOption;
//extern RNDBindingOption NSContentPlacementTagBindingOption;
//extern RNDBindingOption NSHandlesContentAsCompoundValueBindingOption;
//extern RNDBindingOption NSInsertsNullPlaceholderBindingOption;
//extern RNDBindingOption NSInvokesSeparatelyWithArrayObjectsBindingOption;
//extern RNDBindingOption NSMultipleValuesPlaceholderBindingOption;
//extern RNDBindingOption NSNoSelectionPlaceholderBindingOption;
//extern RNDBindingOption NSNotApplicablePlaceholderBindingOption;
//extern RNDBindingOption NSNullPlaceholderBindingOption;
//extern RNDBindingOption NSRaisesForNotApplicableKeysBindingOption;
//extern RNDBindingOption NSPredicateFormatBindingOption;
//extern RNDBindingOption NSSelectorNameBindingOption;
//extern RNDBindingOption NSSelectsAllWhenSettingContentBindingOption;
//extern RNDBindingOption NSValidatesImmediatelyBindingOption;
//extern RNDBindingOption NSValueTransformerNameBindingOption;
//extern RNDBindingOption NSValueTransformerBindingOption;

NS_ASSUME_NONNULL_END
