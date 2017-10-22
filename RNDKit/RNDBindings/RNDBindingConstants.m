//
//  RNDBindings.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/11/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//
#import "RNDBindingConstants.h"

#pragma mark - RNDBindingType Definitions
RNDBindingType RNDBindingTypeSimpleValue = @"RNDBindingTypeSimpleValue";
RNDBindingType RNDBindingTypeSimpleValueReadOnly = @"RNDBindingTypeSimpleValueReadOnly";
RNDBindingType RNDBindingTypeSimpleValueWriteOnly = @"RNDBindingTypeSimpleValueWriteOnly";
RNDBindingType RNDBindingTypeMultiValueAND = @"RNDBindingTypeMultiValueAND";
RNDBindingType RNDBindingTypeMultiValueOR = @"RNDBindingTypeMultiValueOR";
RNDBindingType RNDBindingTypeMultiValueArgument = @"RNDBindingTypeMultiValueArgument";
RNDBindingType RNDBindingTypeMultiValueWithPattern = @"RNDBindingTypeMultiValueWithPattern";
RNDBindingType RNDBindingTypeMultiValuePredicate = @"RNDBindingTypeMultiValuePredicate";

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
RNDBindingName RNDAlignmentBindingName = @"RNDAlignmentBindingName";
RNDBindingName RNDAlternateImageBindingName = @"RNDAlternateImageBindingName";
RNDBindingName RNDAlternateTitleBindingName = @"RNDAlternateTitleBindingName";
RNDBindingName RNDAnimateBindingName = @"RNDAnimateBindingName";
RNDBindingName RNDAnimationDelayBindingName = @"RNDAnimationDelayBindingName";
RNDBindingName RNDArgumentBindingName = @"RNDArgumentBindingName";
RNDBindingName RNDAttributedStringBindingName = @"RNDAttributedStringBindingName";
RNDBindingName RNDContentArrayBindingName = @"RNDContentArrayBindingName";
RNDBindingName RNDContentArrayForMultipleSelectionBindingName = @"RNDContentArrayForMultipleSelectionBindingName";
RNDBindingName RNDContentBindingName = @"RNDContentBindingName";
RNDBindingName RNDContentDictionaryBindingName = @"RNDContentDictionaryBindingName";
RNDBindingName RNDContentHeightBindingName = @"RNDContentHeightBindingName";
RNDBindingName RNDContentObjectBindingName = @"RNDContentObjectBindingName";
RNDBindingName RNDContentObjectsBindingName = @"RNDContentObjectsBindingName";
RNDBindingName RNDContentSetBindingName = @"RNDContentSetBindingName";
RNDBindingName RNDContentValuesBindingName = @"RNDContentValuesBindingName";
RNDBindingName RNDContentWidthBindingName = @"RNDContentWidthBindingName";
RNDBindingName RNDCriticalValueBindingName = @"RNDCriticalValueBindingName";
RNDBindingName RNDDataBindingName = @"RNDDataBindingName";
RNDBindingName RNDDisplayPatternTitleBindingName = @"RNDDisplayPatternTitleBindingName";
RNDBindingName RNDDisplayPatternValueBindingName = @"RNDDisplayPatternValueBindingName";
RNDBindingName RNDDocumentEditedBindingName = @"RNDDocumentEditedBindingName";
RNDBindingName RNDDoubleClickArgumentBindingName = @"RNDDoubleClickArgumentBindingName";
RNDBindingName RNDDoubleClickTargetBindingName = @"RNDDoubleClickTargetBindingName";
RNDBindingName RNDEditableBindingName = @"RNDEditableBindingName";
RNDBindingName RNDEnabledBindingName = @"RNDEnabledBindingName";
RNDBindingName RNDExcludedKeysBindingName = @"RNDExcludedKeysBindingName";
RNDBindingName RNDFilterPredicateBindingName = @"RNDFilterPredicateBindingName";
RNDBindingName RNDFontBindingName = @"RNDFontBindingName";
RNDBindingName RNDFontBoldBindingName = @"RNDFontBoldBindingName";
RNDBindingName RNDFontFamilyNameBindingName = @"RNDFontFamilyNameBindingName";
RNDBindingName RNDFontItalicBindingName = @"RNDFontItalicBindingName";
RNDBindingName RNDFontNameBindingName = @"RNDFontNameBindingName";
RNDBindingName RNDFontSizeBindingName = @"RNDFontSizeBindingName";
RNDBindingName RNDHeaderTitleBindingName = @"RNDHeaderTitleBindingName";
RNDBindingName RNDHiddenBindingName = @"RNDHiddenBindingName";
RNDBindingName RNDImageBindingName = @"RNDImageBindingName";
RNDBindingName RNDIncludedKeysBindingName = @"RNDIncludedKeysBindingName";
RNDBindingName RNDInitialKeyBindingName = @"RNDInitialKeyBindingName";
RNDBindingName RNDInitialValueBindingName = @"RNDInitialValueBindingName";
RNDBindingName RNDIsIndeterminateBindingName = @"RNDIsIndeterminateBindingName";
RNDBindingName RNDLabelBindingName = @"RNDLabelBindingName";
RNDBindingName RNDLocalizedKeyDictionaryBindingName = @"RNDLocalizedKeyDictionaryBindingName";
RNDBindingName RNDManagedObjectContextBindingName = @"RNDManagedObjectContextBindingName";
RNDBindingName RNDMaximumRecentsBindingName = @"RNDMaximumRecentsBindingName";
RNDBindingName RNDMaxValueBindingName = @"RNDMaxValueBindingName";
RNDBindingName RNDMaxWidthBindingName = @"RNDMaxWidthBindingName";
RNDBindingName RNDMinValueBindingName = @"RNDMinValueBindingName";
RNDBindingName RNDMinWidthBindingName = @"RNDMinWidthBindingName";
RNDBindingName RNDMixedStateImageBindingName = @"RNDMixedStateImageBindingName";
RNDBindingName RNDOffStateImageBindingName = @"RNDOffStateImageBindingName";
RNDBindingName RNDOnStateImageBindingName = @"RNDOnStateImageBindingName";
RNDBindingName RNDPositioningRectBindingName = @"RNDPositioningRectBindingName";
RNDBindingName RNDPredicateBindingName = @"RNDPredicateBindingName";
RNDBindingName RNDRecentSearchesBindingName = @"RNDRecentSearchesBindingName";
RNDBindingName RNDRepresentedFilenameBindingName = @"RNDRepresentedFilenameBindingName";
RNDBindingName RNDRowHeightBindingName = @"RNDRowHeightBindingName";
RNDBindingName RNDSelectedIdentifierBindingName = @"RNDSelectedIdentifierBindingName";
RNDBindingName RNDSelectedIndexBindingName = @"RNDSelectedIndexBindingName";
RNDBindingName RNDSelectedLabelBindingName = @"RNDSelectedLabelBindingName";
RNDBindingName RNDSelectedObjectBindingName = @"RNDSelectedObjectBindingName";
RNDBindingName RNDSelectedObjectsBindingName = @"RNDSelectedObjectsBindingName";
RNDBindingName RNDSelectedTagBindingName = @"RNDSelectedTagBindingName";
RNDBindingName RNDSelectedValueBindingName = @"RNDSelectedValueBindingName";
RNDBindingName RNDSelectedValuesBindingName = @"RNDSelectedValuesBindingName";
RNDBindingName RNDSelectionIndexesBindingName = @"RNDSelectionIndexesBindingName";
RNDBindingName RNDSelectionIndexPathsBindingName = @"RNDSelectionIndexPathsBindingName";
RNDBindingName RNDSortDescriptorsBindingName = @"RNDSortDescriptorsBindingName";
RNDBindingName RNDTargetBindingName = @"RNDTargetBindingName";
RNDBindingName RNDTextColorBindingName = @"RNDTextColorBindingName";
RNDBindingName RNDTitleBindingName = @"RNDTitleBindingName";
RNDBindingName RNDToolTipBindingName = @"RNDToolTipBindingName";
RNDBindingName RNDTransparentBindingName = @"RNDTransparentBindingName";
RNDBindingName RNDValueBindingName = @"RNDValueBindingName";
RNDBindingName RNDValuePathBindingName = @"RNDValuePathBindingName";
RNDBindingName RNDValueURLBindingName = @"RNDValueURLBindingName";
RNDBindingName RNDVisibleBindingName = @"RNDVisibleBindingName";
RNDBindingName RNDWarningValueBindingName = @"RNDWarningValueBindingName";
RNDBindingName RNDWidthBindingName = @"RNDWidthBindingName";

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
