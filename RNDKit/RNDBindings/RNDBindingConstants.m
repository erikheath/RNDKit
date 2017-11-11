//
//  RNDBindings.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/11/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//
#import "RNDBindingConstants.h"

#pragma mark - RNDMarkers
RNDBindingMarker RNDBindingMultipleValuesMarker = @"RNDBindingMultipleValuesMarker";
RNDBindingMarker RNDBindingNoSelectionMarker = @"RNDBindingNoSelectionMarker";
RNDBindingMarker RNDBindingNotApplicableMarker = @"RNDBindingNotApplicableMarker";
RNDBindingMarker RNDBindingNullValueMarker = @"RNDBindingNullValueMarker";

#pragma mark - RNDArgumentNames
RNDArgument RNDEventArgument = @"RNDEventArgument";
RNDArgument RNDSenderArgument = @"RNDSenderArgument";
RNDArgument RNDContextArgument = @"RNDContextArgument";
RNDArgument RNDBindingSelectorArgument = @"RNDBindingSelectorArgument";
RNDArgument RNDUnbindingSelectorArgument = @"RNDUnbindingSelectorArgument";
RNDArgument RNDActionSelectorArgument = @"RNDActionSelectorArgument";
RNDArgument RNDBinderArgument = @"RNDBinderArgument";
RNDArgument RNDObserverArgument = @"RNDObserverArgument";

#pragma mark - RNDNotifications
RNDBindingNotifications RNDValueOfObserverObjectDidChange = @"RNDValueOfObserverObjectDidChange";
RNDBindingNotifications RNDValueOfObservedObjectDidChange = @"RNDValueOfObservedObjectDidChange";

#pragma mark - RNDBindingType Definitions
RNDBinderType RNDBindingTypeSimpleValue = @"RNDBindingTypeSimpleValue";
RNDBinderType RNDBindingTypeSimpleValueReadOnly = @"RNDBindingTypeSimpleValueReadOnly";
RNDBinderType RNDBindingTypeSimpleValueWriteOnly = @"RNDBindingTypeSimpleValueWriteOnly";
RNDBinderType RNDBindingTypeMultiValueAND = @"RNDBindingTypeMultiValueAND";
RNDBinderType RNDBindingTypeMultiValueOR = @"RNDBindingTypeMultiValueOR";
RNDBinderType RNDBindingTypeMultiValueArgument = @"RNDBindingTypeMultiValueArgument";
RNDBinderType RNDBindingTypeMultiValueWithPattern = @"RNDBindingTypeMultiValueWithPattern";
RNDBinderType RNDBindingTypeMultiValuePredicate = @"RNDBindingTypeMultiValuePredicate";

#pragma mark - RNDBindingInfoKey Definitions
RNDBindingInfoKey RNDBindingInfoTypeKey = @"RNDBindingInfoTypeKey";
RNDBindingInfoKey RNDBindingInfoOptionsKey = @"RNDBindingInfoOptionsKey";
RNDBindingInfoKey RNDBindingInfoNameKey = @"RNDBindingInfoNameKey";
RNDBindingInfoKey RNDBindingInfoExclusionsKey = @"RNDBindingInfoExclusionsKey";
RNDBindingInfoKey RNDBindingInfoRequirementsKey = @"RNDBindingInfoRequirementsKey";
RNDBindingInfoKey RNDBindingInfoValueTypeKey = @"RNDBindingInfoValueTypeKey";
RNDBindingInfoKey RNDBindingInfoValueClassKey = @"RNDBindingInfoValueClassKey";
RNDBindingInfoKey RNDBindingInfoDefaultValueKey = @"RNDBindingInfoDefaultValueKey";
RNDBindingInfoKey RNDBindingInfoObservedObjectKey = @"RNDBindingInfoObservedObjectKey";
RNDBindingInfoKey RNDBindingInfoObservedKeyPathKey = @"RNDBindingInfoObservedKeyPathKey";
RNDBindingInfoKey RNDBindingInfoGroupKey = @"RNDBindingInfoGroupKey";
RNDBindingInfoKey RNDBindingInfoBinderClassKey = @"RNDBindingInfoBinderClassKey";
RNDBindingInfoKey RNDBindingInfoBindingClassKey = @"RNDBindingInfoBindingClassKey";

#pragma mark - RNDBindingValueType
RNDBindingValueType RNDBindingValueInt8Type = @"RNDBindingValueInt8Type";
RNDBindingValueType RNDBindingValueInt16Type = @"RNDBindingValueInt16Type";
RNDBindingValueType RNDBindingValueInt32Type = @"RNDBindingValueInt32Type";
RNDBindingValueType RNDBindingValueInt64Type = @"RNDBindingValueInt64Type";
RNDBindingValueType RNDBindingValueFloatType = @"RNDBindingValueFloatType";
RNDBindingValueType RNDBindingValueDoubleType = @"RNDBindingValueDoubleType";
RNDBindingValueType RNDBindingValueStringType = @"RNDBindingValueStringType";
RNDBindingValueType RNDBindingValueUUIDType = @"RNDBindingValueUUIDType";
RNDBindingValueType RNDBindingValueURLType = @"RNDBindingValueURLType";
RNDBindingValueType RNDBindingValueDateType = @"RNDBindingValueDateType";
RNDBindingValueType RNDBindingValueBooleanType = @"RNDBindingValueBooleanType";
RNDBindingValueType RNDBindingValueDecimalType = @"RNDBindingValueDecimalType";
RNDBindingValueType RNDBindingValueBinaryType = @"RNDBindingValueBinaryType";
RNDBindingValueType RNDBindingValueUndefinedType = @"RNDBindingValueUndefinedType";
RNDBindingValueType RNDBindingValueObjectIDType = @"RNDBindingValueObjectIDType";
RNDBindingValueType RNDBindingValueTransformableType = @"RNDBindingValueTransformableType";

#pragma mark - RNDBindingKeyPathComponent Definitions
RNDBindingKeyPathComponent RNDBindingCurrentSelectionKeyPathComponent = @"selection";
RNDBindingKeyPathComponent RNDBindingSelectedObjectsKeyPathComponent = @"selectedObjects";
RNDBindingKeyPathComponent RNDBindingArrangedObjectsKeyPathComponent = @"arrangedObjects";
RNDBindingKeyPathComponent RNDBindingContentObjectKeyPathComponent = @"content";

#pragma mark - RNDBindingName Definitions
RNDBinderName RNDAlignmentBindingName = @"RNDAlignmentBindingName";
RNDBinderName RNDAlternateImageBindingName = @"RNDAlternateImageBindingName";
RNDBinderName RNDAlternateTitleBindingName = @"RNDAlternateTitleBindingName";
RNDBinderName RNDAnimateBindingName = @"RNDAnimateBindingName";
RNDBinderName RNDAnimationDelayBindingName = @"RNDAnimationDelayBindingName";
RNDBinderName RNDArgumentBindingName = @"RNDArgumentBindingName";
RNDBinderName RNDAttributedStringBindingName = @"RNDAttributedStringBindingName";
RNDBinderName RNDContentArrayBindingName = @"RNDContentArrayBindingName";
RNDBinderName RNDContentArrayForMultipleSelectionBindingName = @"RNDContentArrayForMultipleSelectionBindingName";
RNDBinderName RNDContentBindingName = @"RNDContentBindingName";
RNDBinderName RNDContentDictionaryBindingName = @"RNDContentDictionaryBindingName";
RNDBinderName RNDContentHeightBindingName = @"RNDContentHeightBindingName";
RNDBinderName RNDContentObjectBindingName = @"RNDContentObjectBindingName";
RNDBinderName RNDContentObjectsBindingName = @"RNDContentObjectsBindingName";
RNDBinderName RNDContentSetBindingName = @"RNDContentSetBindingName";
RNDBinderName RNDContentValuesBindingName = @"RNDContentValuesBindingName";
RNDBinderName RNDContentWidthBindingName = @"RNDContentWidthBindingName";
RNDBinderName RNDCriticalValueBindingName = @"RNDCriticalValueBindingName";
RNDBinderName RNDDataBindingName = @"RNDDataBindingName";
RNDBinderName RNDDisplayPatternTitleBindingName = @"RNDDisplayPatternTitleBindingName";
RNDBinderName RNDDisplayPatternValueBindingName = @"RNDDisplayPatternValueBindingName";
RNDBinderName RNDDocumentEditedBindingName = @"RNDDocumentEditedBindingName";
RNDBinderName RNDDoubleClickArgumentBindingName = @"RNDDoubleClickArgumentBindingName";
RNDBinderName RNDDoubleClickTargetBindingName = @"RNDDoubleClickTargetBindingName";
RNDBinderName RNDEditableBindingName = @"RNDEditableBindingName";
RNDBinderName RNDEnabledBindingName = @"RNDEnabledBindingName";
RNDBinderName RNDExcludedKeysBindingName = @"RNDExcludedKeysBindingName";
RNDBinderName RNDFilterPredicateBindingName = @"RNDFilterPredicateBindingName";
RNDBinderName RNDFontBindingName = @"RNDFontBindingName";
RNDBinderName RNDFontBoldBindingName = @"RNDFontBoldBindingName";
RNDBinderName RNDFontFamilyNameBindingName = @"RNDFontFamilyNameBindingName";
RNDBinderName RNDFontItalicBindingName = @"RNDFontItalicBindingName";
RNDBinderName RNDFontNameBindingName = @"RNDFontNameBindingName";
RNDBinderName RNDFontSizeBindingName = @"RNDFontSizeBindingName";
RNDBinderName RNDHeaderTitleBindingName = @"RNDHeaderTitleBindingName";
RNDBinderName RNDHiddenBindingName = @"RNDHiddenBindingName";
RNDBinderName RNDImageBindingName = @"RNDImageBindingName";
RNDBinderName RNDIncludedKeysBindingName = @"RNDIncludedKeysBindingName";
RNDBinderName RNDInitialKeyBindingName = @"RNDInitialKeyBindingName";
RNDBinderName RNDInitialValueBindingName = @"RNDInitialValueBindingName";
RNDBinderName RNDIsIndeterminateBindingName = @"RNDIsIndeterminateBindingName";
RNDBinderName RNDLabelBindingName = @"RNDLabelBindingName";
RNDBinderName RNDLocalizedKeyDictionaryBindingName = @"RNDLocalizedKeyDictionaryBindingName";
RNDBinderName RNDManagedObjectContextBindingName = @"RNDManagedObjectContextBindingName";
RNDBinderName RNDMaximumRecentsBindingName = @"RNDMaximumRecentsBindingName";
RNDBinderName RNDMaxValueBindingName = @"RNDMaxValueBindingName";
RNDBinderName RNDMaxWidthBindingName = @"RNDMaxWidthBindingName";
RNDBinderName RNDMinValueBindingName = @"RNDMinValueBindingName";
RNDBinderName RNDMinWidthBindingName = @"RNDMinWidthBindingName";
RNDBinderName RNDMixedStateImageBindingName = @"RNDMixedStateImageBindingName";
RNDBinderName RNDOffStateImageBindingName = @"RNDOffStateImageBindingName";
RNDBinderName RNDOnStateImageBindingName = @"RNDOnStateImageBindingName";
RNDBinderName RNDPositioningRectBindingName = @"RNDPositioningRectBindingName";
RNDBinderName RNDPredicateBindingName = @"RNDPredicateBindingName";
RNDBinderName RNDRecentSearchesBindingName = @"RNDRecentSearchesBindingName";
RNDBinderName RNDRepresentedFilenameBindingName = @"RNDRepresentedFilenameBindingName";
RNDBinderName RNDRowHeightBindingName = @"RNDRowHeightBindingName";
RNDBinderName RNDSelectedIdentifierBindingName = @"RNDSelectedIdentifierBindingName";
RNDBinderName RNDSelectedIndexBindingName = @"RNDSelectedIndexBindingName";
RNDBinderName RNDSelectedLabelBindingName = @"RNDSelectedLabelBindingName";
RNDBinderName RNDSelectedObjectBindingName = @"RNDSelectedObjectBindingName";
RNDBinderName RNDSelectedObjectsBindingName = @"RNDSelectedObjectsBindingName";
RNDBinderName RNDSelectedTagBindingName = @"RNDSelectedTagBindingName";
RNDBinderName RNDSelectedValueBindingName = @"RNDSelectedValueBindingName";
RNDBinderName RNDSelectedValuesBindingName = @"RNDSelectedValuesBindingName";
RNDBinderName RNDSelectionIndexesBindingName = @"RNDSelectionIndexesBindingName";
RNDBinderName RNDSelectionIndexPathsBindingName = @"RNDSelectionIndexPathsBindingName";
RNDBinderName RNDSortDescriptorsBindingName = @"RNDSortDescriptorsBindingName";
RNDBinderName RNDTargetBindingName = @"RNDTargetBindingName";
RNDBinderName RNDTextColorBindingName = @"RNDTextColorBindingName";
RNDBinderName RNDTitleBindingName = @"RNDTitleBindingName";
RNDBinderName RNDToolTipBindingName = @"RNDToolTipBindingName";
RNDBinderName RNDTransparentBindingName = @"RNDTransparentBindingName";
RNDBinderName RNDValueBindingName = @"RNDValueBindingName";
RNDBinderName RNDValuePathBindingName = @"RNDValuePathBindingName";
RNDBinderName RNDValueURLBindingName = @"RNDValueURLBindingName";
RNDBinderName RNDVisibleBindingName = @"RNDVisibleBindingName";
RNDBinderName RNDWarningValueBindingName = @"RNDWarningValueBindingName";
RNDBinderName RNDWidthBindingName = @"RNDWidthBindingName";

#pragma mark - RNDBindingOption Definitions
RNDBindingOption RNDAllowsEditingMultipleValuesSelectionBindingOption = @"RNDAllowsEditingMultipleValuesSelectionBindingOption";
RNDBindingOption RNDAllowsNullArgumentBindingOption = @"RNDAllowsNullArgumentBindingOption";
RNDBindingOption RNDAlwaysPresentsApplicationModalAlertsBindingOption = @"RNDAlwaysPresentsApplicationModalAlertsBindingOption";
RNDBindingOption RNDConditionallySetsEditableBindingOption = @"RNDConditionallySetsEditableBindingOption";
RNDBindingOption RNDConditionallySetsEnabledBindingOption = @"RNDConditionallySetsEnabledBindingOption";
RNDBindingOption RNDConditionallySetsHiddenBindingOption = @"RNDConditionallySetsHiddenBindingOption";
RNDBindingOption RNDContinuouslyUpdatesValueBindingOption = @"RNDContinuouslyUpdatesValueBindingOption";
RNDBindingOption RNDCreatesSortDescriptorBindingOption = @"RNDCreatesSortDescriptorBindingOption";
RNDBindingOption RNDDeletesObjectsOnRemoveBindingsOption = @"RNDDeletesObjectsOnRemoveBindingsOption";
RNDBindingOption RNDDisplayNameBindingOption = @"RNDDisplayNameBindingOption";
RNDBindingOption RNDDisplayPatternBindingOption = @"RNDDisplayPatternBindingOption";
RNDBindingOption RNDContentPlacementTagBindingOption = @"RNDContentPlacementTagBindingOption";
RNDBindingOption RNDHandlesContentAsCompoundValueBindingOption = @"RNDHandlesContentAsCompoundValueBindingOption";
RNDBindingOption RNDInsertsNullPlaceholderBindingOption = @"RNDInsertsNullPlaceholderBindingOption";
RNDBindingOption RNDInvokesSeparatelyWithArrayObjectsBindingOption = @"RNDInvokesSeparatelyWithArrayObjectsBindingOption";
RNDBindingOption RNDMultipleValuesPlaceholderBindingOption = @"RNDMultipleValuesPlaceholderBindingOption";
RNDBindingOption RNDNoSelectionPlaceholderBindingOption = @"RNDNoSelectionPlaceholderBindingOption";
RNDBindingOption RNDNotApplicablePlaceholderBindingOption = @"RNDNotApplicablePlaceholderBindingOption";
RNDBindingOption RNDNullPlaceholderBindingOption = @"RNDNullPlaceholderBindingOption";
RNDBindingOption RNDRaisesForNotApplicableKeysBindingOption = @"RNDRaisesForNotApplicableKeysBindingOption";
RNDBindingOption RNDPredicateFormatBindingOption = @"RNDPredicateFormatBindingOption";
RNDBindingOption RNDSelectorNameBindingOption = @"RNDSelectorNameBindingOption";
RNDBindingOption RNDSelectsAllWhenSettingContentBindingOption = @"RNDSelectsAllWhenSettingContentBindingOption";
RNDBindingOption RNDValidatesImmediatelyBindingOption = @"RNDValidatesImmediatelyBindingOption";
RNDBindingOption RNDValueTransformerNameBindingOption = @"RNDValueTransformerNameBindingOption";
RNDBindingOption RNDValueTransformerBindingOption = @"RNDValueTransformerBindingOption";
RNDBindingOption RNDArgumentPositionBindingOption = @"RNDArgumentPositionBindingOption";
RNDBindingOption RNDActionInvocationBindingOption = @"RNDActionInvocationBindingOption";
RNDBindingOption RNDMonitorsObservedObjectOption = @"RNDMonitorsObservedObjectOption";
RNDBindingOption RNDArgumentNameOption = @"RNDArgumentNameOption";
