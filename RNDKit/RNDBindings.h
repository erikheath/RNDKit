//
//  RNDBindings.h
//  RNDKit
//
//  Created by Erikheath Thomas on 6/29/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - RNDMarkers
typedef NSString * RNDBindingMarker NS_STRING_ENUM;
extern RNDBindingMarker RNDBindingMultipleValuesMarker;
extern RNDBindingMarker RNDBindingNoSelectionMarker;
extern RNDBindingMarker RNDBindingNotApplicableMarker;

extern BOOL RNDIsControllerMarker(__nullable id object);


#pragma mark - RNDBindingType
typedef NSString * RNDBindingType NS_STRING_ENUM;
extern RNDBindingType RNDBindingTypeSimpleValue;
extern RNDBindingType RNDBindingTypeSimpleValueReadOnly;
extern RNDBindingType RNDBindingTypeMultiValueAND;
extern RNDBindingType RNDBindingTypeMultiValueOR;
extern RNDBindingType RNDBindingTypeMultiValueArgument;
extern RNDBindingType RNDBindingTypeMultiValueWithPattern;
extern RNDBindingType RNDBindingTypeMultiValuePredicate;

#pragma mark - RNDBindingInfoKey
typedef NSString * RNDBindingInfoKey NS_STRING_ENUM;
extern RNDBindingInfoKey RNDBindingInfoTypeKey;
extern RNDBindingInfoKey RNDBindingInfoOptionsKey;
extern RNDBindingInfoKey RNDBindingInfoNameKey;
extern RNDBindingInfoKey RNDBindingInfoExclusionsKey;
extern RNDBindingInfoKey RNDBindingInfoRequirementsKey;
extern RNDBindingInfoKey RNDBindingInfoValueTypeKey;
extern RNDBindingInfoKey RNDBindingInfoValueClassKey;
extern RNDBindingInfoKey RNDBindingInfoDefaultValueKey;
extern RNDBindingInfoKey RNDBindingInfoObservedObjectKey;
extern RNDBindingInfoKey RNDBindingInfoObservedKeyPathKey;
extern RNDBindingInfoKey RNDBindingInfoGroupKey;

#pragma mark - RNDBindingInfoGroupType
typedef NSString * RNDBindingInfoGroupType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupValueType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupValueWithPatternType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupAvailabilityType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupFontType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupParametersType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupTextColorType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupTitleType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupTitleWithPatternType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupControllerContentType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupControllerContentWithParametersType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupActionInvocationType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupTableContentType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupTabViewItemSelectionType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupSegmentSelectionType;
extern RNDBindingInfoGroupType RNDBindingInfoGroupSearchType;

#pragma mark - RNDBindingValueType
typedef NSString * RNDBindingValueType;
extern RNDBindingValueType RNDBindingValueInt8Type;
extern RNDBindingValueType RNDBindingValueInt16Type;
extern RNDBindingValueType RNDBindingValueInt32Type;
extern RNDBindingValueType RNDBindingValueInt64Type;
extern RNDBindingValueType RNDBindingValueFloatType;
extern RNDBindingValueType RNDBindingValueDoubleType;
extern RNDBindingValueType RNDBindingValueStringType;
extern RNDBindingValueType RNDBindingValueUUIDType;
extern RNDBindingValueType RNDBindingValueURLType;
extern RNDBindingValueType RNDBindingValueDateType;
extern RNDBindingValueType RNDBindingValueBooleanType;
extern RNDBindingValueType RNDBindingValueDecimalType;
extern RNDBindingValueType RNDBindingValueBinaryType;
extern RNDBindingValueType RNDBindingValueUndefinedType;
extern RNDBindingValueType RNDBindingValueObjectIDType;
extern RNDBindingValueType RNDBindingValueTransformableType;


#pragma mark - RNDBindingKeyPathComponent
typedef NSString * RNDBindingKeyPathComponent NS_STRING_ENUM;
extern RNDBindingKeyPathComponent RNDBindingCurrentSelectionKeyPathComponent;
extern RNDBindingKeyPathComponent RNDBindingSelectedObjectsKeyPathComponent;
extern RNDBindingKeyPathComponent RNDBindingArrangedObjectsKeyPathComponent;
extern RNDBindingKeyPathComponent RNDBindingContentObjectKeyPathComponent;

#pragma mark - RNDBindingName
typedef NSString * RNDBindingName NS_EXTENSIBLE_STRING_ENUM;
extern RNDBindingName RNDAlignmentBindingName;
extern RNDBindingName RNDAlternateImageBindingName;
extern RNDBindingName RNDAlternateTitleBindingName;
extern RNDBindingName RNDAnimateBindingName;
extern RNDBindingName RNDAnimationDelayBindingName;
extern RNDBindingName RNDArgumentBindingName;
extern RNDBindingName RNDAttributedStringBindingName;
extern RNDBindingName RNDContentArrayBindingName;
extern RNDBindingName RNDContentArrayForMultipleSelectionBindingName;
extern RNDBindingName RNDContentBindingName;
extern RNDBindingName RNDContentDictionaryBindingName;
extern RNDBindingName RNDContentHeightBindingName;
extern RNDBindingName RNDContentObjectBindingName;
extern RNDBindingName RNDContentObjectsBindingName;
extern RNDBindingName RNDContentSetBindingName;
extern RNDBindingName RNDContentValuesBindingName;
extern RNDBindingName RNDContentWidthBindingName;
extern RNDBindingName RNDCriticalValueBindingName;
extern RNDBindingName RNDDataBindingName;
extern RNDBindingName RNDDisplayPatternTitleBindingName;
extern RNDBindingName RNDDisplayPatternValueBindingName;
extern RNDBindingName RNDDocumentEditedBindingName;
extern RNDBindingName RNDDoubleClickArgumentBindingName;
extern RNDBindingName RNDDoubleClickTargetBindingName;
extern RNDBindingName RNDEditableBindingName;
extern RNDBindingName RNDEnabledBindingName;
extern RNDBindingName RNDExcludedKeysBindingName;
extern RNDBindingName RNDFilterPredicateBindingName;
extern RNDBindingName RNDFontBindingName;
extern RNDBindingName RNDFontBoldBindingName;
extern RNDBindingName RNDFontFamilyNameBindingName;
extern RNDBindingName RNDFontItalicBindingName;
extern RNDBindingName RNDFontNameBindingName;
extern RNDBindingName RNDFontSizeBindingName;
extern RNDBindingName RNDHeaderTitleBindingName;
extern RNDBindingName RNDHiddenBindingName;
extern RNDBindingName RNDImageBindingName;
extern RNDBindingName RNDIncludedKeysBindingName;
extern RNDBindingName RNDInitialKeyBindingName;
extern RNDBindingName RNDInitialValueBindingName;
extern RNDBindingName RNDIsIndeterminateBindingName;
extern RNDBindingName RNDLabelBindingName;
extern RNDBindingName RNDLocalizedKeyDictionaryBindingName;
extern RNDBindingName RNDManagedObjectContextBindingName;
extern RNDBindingName RNDMaximumRecentsBindingName;
extern RNDBindingName RNDMaxValueBindingName;
extern RNDBindingName RNDMaxWidthBindingName;
extern RNDBindingName RNDMinValueBindingName;
extern RNDBindingName RNDMinWidthBindingName;
extern RNDBindingName RNDMixedStateImageBindingName;
extern RNDBindingName RNDOffStateImageBindingName;
extern RNDBindingName RNDOnStateImageBindingName;
extern RNDBindingName RNDPositioningRectBindingName;
extern RNDBindingName RNDPredicateBindingName;
extern RNDBindingName RNDRecentSearchesBindingName;
extern RNDBindingName RNDRepresentedFilenameBindingName;
extern RNDBindingName RNDRowHeightBindingName;
extern RNDBindingName RNDSelectedIdentifierBindingName;
extern RNDBindingName RNDSelectedIndexBindingName;
extern RNDBindingName RNDSelectedLabelBindingName;
extern RNDBindingName RNDSelectedObjectBindingName;
extern RNDBindingName RNDSelectedObjectsBindingName;
extern RNDBindingName RNDSelectedTagBindingName;
extern RNDBindingName RNDSelectedValueBindingName;
extern RNDBindingName RNDSelectedValuesBindingName;
extern RNDBindingName RNDSelectionIndexesBindingName;
extern RNDBindingName RNDSelectionIndexPathsBindingName;
extern RNDBindingName RNDSortDescriptorsBindingName;
extern RNDBindingName RNDTargetBindingName;
extern RNDBindingName RNDTextColorBindingName;
extern RNDBindingName RNDTitleBindingName;
extern RNDBindingName RNDToolTipBindingName;
extern RNDBindingName RNDTransparentBindingName;
extern RNDBindingName RNDValueBindingName;
extern RNDBindingName RNDValuePathBindingName;
extern RNDBindingName RNDValueURLBindingName;
extern RNDBindingName RNDVisibleBindingName;
extern RNDBindingName RNDWarningValueBindingName;
extern RNDBindingName RNDWidthBindingName;

#pragma mark - RNDBindingOption
typedef NSString * RNDBindingOption NS_STRING_ENUM;
extern RNDBindingOption RNDAllowsEditingMultipleValuesSelectionBindingOption;
extern RNDBindingOption RNDAllowsNullArgumentBindingOption;
extern RNDBindingOption RNDAlwaysPresentsApplicationModalAlertsBindingOption;
extern RNDBindingOption RNDConditionallySetsEditableBindingOption;
extern RNDBindingOption RNDConditionallySetsEnabledBindingOption;
extern RNDBindingOption RNDConditionallySetsHiddenBindingOption;
extern RNDBindingOption RNDContinuouslyUpdatesValueBindingOption;
extern RNDBindingOption RNDCreatesSortDescriptorBindingOption;
extern RNDBindingOption RNDDeletesObjectsOnRemoveBindingsOption;
extern RNDBindingOption RNDDisplayNameBindingOption;
extern RNDBindingOption RNDDisplayPatternBindingOption;
extern RNDBindingOption RNDContentPlacementTagBindingOption;
extern RNDBindingOption RNDHandlesContentAsCompoundValueBindingOption;
extern RNDBindingOption RNDInsertsNullPlaceholderBindingOption;
extern RNDBindingOption RNDInvokesSeparatelyWithArrayObjectsBindingOption;
extern RNDBindingOption RNDMultipleValuesPlaceholderBindingOption;
extern RNDBindingOption RNDNoSelectionPlaceholderBindingOption;
extern RNDBindingOption RNDNotApplicablePlaceholderBindingOption;
extern RNDBindingOption RNDNullPlaceholderBindingOption;
extern RNDBindingOption RNDRaisesForNotApplicableKeysBindingOption;
extern RNDBindingOption RNDPredicateFormatBindingOption;
extern RNDBindingOption RNDSelectorNameBindingOption;
extern RNDBindingOption RNDSelectsAllWhenSettingContentBindingOption;
extern RNDBindingOption RNDValidatesImmediatelyBindingOption;
extern RNDBindingOption RNDValueTransformerNameBindingOption;
extern RNDBindingOption RNDValueTransformerBindingOption;

#pragma mark - RNDBinding Protocol Declarations

@protocol RNDEditorDelegate;

@protocol RNDKeyValueBindingCreation <NSObject>

+ (void)exposeBinding:(RNDBindingName)bindingName;    // bindings specified here will be exposed automatically in -exposedBindings (unless implementations explicitly filter them out, for example in subclasses)

@property (class, readonly, copy) NSArray<RNDBindingName> *exposedBindings;   // for a new key exposed through this method, the default implementation simply falls back to key-value coding
@property (class, readonly, copy) NSArray<RNDBindingName> *allExposedBindings;
@property (class, readonly, copy) NSArray<RNDBindingName> *defaultBindings;

- (nullable Class)valueClassForBinding:(RNDBindingName)bindingName;    // optional - mostly for matching transformers

/* Bindings are considered to be a property of the object which is bound (the object the following two methods are sent to) and all information related to bindings should be retained by the object; all standard bindings on AppKit objects (views, cells, table columns, controllers) unbind their bindings automatically when they are released, but if you create key-value bindings for other kind of objects, you need to make sure that you remove those bindings when you release them (observed objects don't retain their observers, so controllers/model objects might continue referencing and messaging the objects that was bound to them).
 */
- (void)bind:(RNDBindingName)bindingName toObject:(id)observable withKeyPath:(NSString *)keyPath options:(nullable NSDictionary<RNDBindingOption, id> *)options;    // placeholders and value transformers are specified in options dictionary
- (void)unbind:(RNDBindingName)bindingName;

/* Returns a dictionary with information about a binding or nil if the binding is not bound (this is mostly for use by subclasses which want to analyze the existing bindings of an object) - the dictionary contains three key/value pairs: RNDObservedObjectKey: object bound, RNDObservedKeyPathKey: key path bound, RNDOptionsKey: dictionary with the options and their values for the bindings.
 */
- (nullable NSDictionary<RNDBindingInfoKey, id> *)infoForBinding:(RNDBindingName)bindingName;

/* Returns an array of NSAttributeDescriptions that describe the options for aBinding. The descriptions are used by Interface Builder to build the options editor UI of the bindings inspector. Each binding may have multiple options. The options and attribute descriptions have 3 properties in common:
 
 - The option "name" is derived from the attribute description name.
 
 - The type of UI built for the option is based on the attribute type.
 
 - The default value shown in the options editor comes from the attribute description's defaultValue.*/


- (NSArray<NSAttributeDescription *> *)optionDescriptionsForBinding:(RNDBindingName)bindingName;


@end

@protocol RNDPlaceholders

- (void)setplaceholder:(nullable id)placeholder forMarker:(nonnull RNDBindingMarker)marker withBinding:(RNDBindingName)bindingName;    // marker can be nil or one of RNDMultipleValuesMarker, RNDNoSelectionMarker, RNDNotApplicableMarker
- (nullable id)placeholderForMarker:(nonnull RNDBindingMarker)marker withBinding:(RNDBindingName)bindingName;    // marker can be nil or one of RNDMultipleValuesMarker, RNDNoSelectionMarker, RNDNotApplicableMarker


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
- (void)commitEditingWithDelegate:(nullable id<RNDEditorDelegate>)delegate didCommitSelector:(nullable SEL)didCommitSelector contextInfo:(nullable void *)contextInfo;


/* During autosaving, commit editing may fail, due to a pending edit.  Rather than interrupt the user with an unexpected alert, this method provides the caller with the option to either present the error or fail silently, leaving the pending edit in place and the user's editing uninterrupted.  This method attempts to commit editing, but if there is a failure the error is returned to the caller to be presented or ignored as appropriate.  If an error occurs while attempting to commit, an implementation of this method should return NO as well as the generated error by reference.  Returns YES if commit is successful.
 
 If you have enabled autosaving in your application, and your application has custom objects that implement or override the NSEditor protocol, you must also implement this method in those NSEditors.
 */
- (BOOL)commitEditingAndReturnError:(NSError **)error;

@end

@protocol RNDEditorDelegate

- (void)editor:(id<RNDEditor>)editor didCommit:(BOOL)didCommit contextInfo:(void *)contextInfo;

@end

/* Protocol implemented by validated objects */

@protocol RNDValidatedUserInterfaceItem
@property (readonly, nullable) SEL action;
@property (readonly) NSInteger tag;
@end

/* Protocol implemented by validator objects */
@protocol RNDUserInterfaceValidations
- (BOOL)validateUserInterfaceItem:(id <RNDValidatedUserInterfaceItem>)item;
@end


#pragma mark - RNDBinding Class Declaration
@interface RNDBinding: NSObject

@property (readonly, nullable) NSArray<NSAttributeDescription *> *bindingOptionsInfo;
@property (readonly, nonnull) RNDBindingType bindingType;
@property (readonly, nonnull) RNDBindingName bindingName;
@property (readonly) NSAttributeType bindingValueType;
@property (readonly, assign, nullable) Class bindingValueClass;
@property (readonly, nullable) NSArray<RNDBindingName> *excludedBindingsWhenActive;
@property (readonly, nullable) NSArray<RNDBindingName> *requiredBindingsWhenActive;
@property (readonly, nonnull) NSString *bindingKey;
@property (readonly, nullable) NSDictionary<RNDBindingMarker, id> *defaultPlaceholders;

+ (NSArray<NSString *> *)RNDBindingNames;
+ (NSArray<NSString *> *)RNDBindingOptions;
+ (NSArray<NSAttributeDescription *> *)bindingOptionsInfoForBindingName:(RNDBindingName)bindingName;
+ (RNDBinding *)bindingInfoForBindingName:(RNDBindingName)bindingName;
+ (void)setDefaultPlaceholder:(nullable id)placeholder forMarker:(RNDBindingMarker)marker withBinding:(RNDBindingName)bindingName;    // marker can be nil or one of RNDBindingMultipleValuesMarker, RNDBindingNoSelectionMarker, RNDBindingNotApplicableMarker
+ (nullable id)defaultPlaceholderForMarker:(RNDBindingMarker)marker withBinding:(RNDBindingName)bindingName;    // marker can be nil or one of RNDBindingMultipleValuesMarker, RNDBindingNoSelectionMarker, RNDBindingNotApplicableMarker


@end


NS_ASSUME_NONNULL_END
