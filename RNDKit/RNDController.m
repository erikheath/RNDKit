//
//  RNDController.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/2/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDController.h"

static NSString *alwaysPresentsApplicationModalAlertsKey = @"alwaysPresentsApplicationModalAlertsKey";
static NSString *refreshesAllModelKeysKey = @"refreshesAllModelKeysKey";
static NSString *multipleObservedModelObjectsKey = @"multipleObservedModelObjectsKey";

@implementation RNDController

- (instancetype)init {
    if ((self = [super init]) != nil) {
        self.editorSet = [NSMutableSet<RNDEditor> new];
        self.declaredKeySet = [NSMutableSet<NSString *> new];
        self.dependentKeyToModelKeyTable = [NSMutableDictionary<NSString *, NSString *> new];
        self.modelKeyToDependentKeyTable = [NSMutableDictionary<NSString *, NSCountedSet<NSString *> *> new];
        self.modelKeysToRefreshEachTime = [NSMutableSet<NSString *> new];
    }
    return self;
}
- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super init]) != nil) {
        self.alwaysPresentsApplicationModalAlerts = [coder decodeBoolForKey:alwaysPresentsApplicationModalAlertsKey];
        self.refreshesAllModelKeys = [coder decodeBoolForKey:refreshesAllModelKeysKey];
        self.multipleObservedModelObjects = [coder decodeBoolForKey:multipleObservedModelObjectsKey];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeBool:self.alwaysPresentsApplicationModalAlerts forKey:alwaysPresentsApplicationModalAlertsKey];
    [aCoder encodeBool:self.refreshesAllModelKeys forKey:refreshesAllModelKeysKey];
    [aCoder encodeBool:self.multipleObservedModelObjects forKey:multipleObservedModelObjectsKey];
}


- (void)objectDidBeginEditing:(id<RNDEditor>)editor {
    [self.editorSet addObject:editor];
}

- (void)objectDidEndEditing:(id<RNDEditor>)editor {
    [self.editorSet removeObject:editor];
}

// Causes the controller to force its editors to discard any pending edits.
- (void)discardEditing {
    for (id<RNDEditor> editor in self.editorSet) {
        [editor discardEditing];
    }
    return;
}

// Causes the controller to force it editors to attempt to commit any pending edits.
- (BOOL)commitEditing {
    for (id<RNDEditor> editor in self.editorSet) {
        if ([editor commitEditing] == NO) {
            return NO;
        }
    }
    return YES;
}

// This method is for objects that have been registered with objectDidBeginEditing. This is not available for controllers.
- (void)commitEditingWithDelegate:(nullable id<RNDEditorDelegate>)delegate didCommitSelector:(nullable SEL)didCommitSelector contextInfo:(nullable void *)contextInfo {
    
    return;
}

// This method is for objects that have been registered with objectDidBeginEditing.
- (BOOL)commitEditingAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return NO;
}

// This method is for actual editors to notify other editors.
- (void)editor:(nonnull id<RNDEditor>)editor didCommit:(BOOL)didCommit contextInfo:(nonnull void *)contextInfo {
    return;
}

@end


// Key Definitions
RNDBindingKeyPathComponent RNDCurrentSelection = @"RNDCurrentSelection";
RNDBindingKeyPathComponent RNDSelectedObjects = @"RNDSelectedObjects";
RNDBindingKeyPathComponent RNDArrangedObjects = @"RNDArrangedObjects";
RNDBindingKeyPathComponent RNDContentObject = @"RNDContentObject";
RNDBindingInfoKey RNDObservedObjectKey = @"RNDObservedObjectKey";
RNDBindingInfoKey RNDObservedKeyPathKey = @"RNDObservedKeyPathKey";
RNDBindingInfoKey RNDOptionsKey = @"RNDOptionsKey";

RNDBindingName RNDAlignmentBinding = @"RNDAlignmentBinding";
RNDBindingName RNDAlternateImageBinding = @"RNDAlternateImageBinding";
RNDBindingName RNDAlternateTitleBinding = @"RNDAlternateTitleBinding";
RNDBindingName RNDAnimateBinding = @"RNDAnimateBinding";
RNDBindingName RNDAnimationDelayBinding = @"RNDAnimationDelayBinding";
RNDBindingName RNDArgumentBinding = @"RNDArgumentBinding";
RNDBindingName RNDAttributedStringBinding = @"RNDAttributedStringBinding";
RNDBindingName RNDContentArrayBinding = @"RNDContentArrayBinding";
RNDBindingName RNDContentArrayForMultipleSelectionBinding = @"RNDContentArrayForMultipleSelectionBinding";
RNDBindingName RNDContentBinding = @"RNDContentBinding";
RNDBindingName RNDContentDictionaryBinding = @"RNDContentDictionaryBinding";
RNDBindingName RNDContentHeightBinding = @"RNDContentHeightBinding";
RNDBindingName RNDContentObjectBinding = @"RNDContentObjectBinding";
RNDBindingName RNDContentObjectsBinding = @"RNDContentObjectsBinding";
RNDBindingName RNDContentSetBinding = @"RNDContentSetBinding";
RNDBindingName RNDContentValuesBinding = @"RNDContentValuesBinding";
RNDBindingName RNDContentWidthBinding = @"RNDContentWidthBinding";
RNDBindingName RNDCriticalValueBinding = @"RNDCriticalValueBinding";
RNDBindingName RNDDataBinding = @"RNDDataBinding";
RNDBindingName RNDDisplayPatternTitleBinding = @"RNDDisplayPatternTitleBinding";
RNDBindingName RNDDisplayPatternValueBinding = @"RNDDisplayPatternValueBinding";
RNDBindingName RNDDocumentEditedBinding = @"RNDDocumentEditedBinding";
RNDBindingName RNDDoubleClickArgumentBinding = @"RNDDoubleClickArgumentBinding";
RNDBindingName RNDDoubleClickTargetBinding = @"RNDDoubleClickTargetBinding";
RNDBindingName RNDEditableBinding = @"RNDEditableBinding";
RNDBindingName RNDEnabledBinding = @"RNDEnabledBinding";
RNDBindingName RNDExcludedKeysBinding = @"RNDExcludedKeysBinding";
RNDBindingName RNDFilterPredicateBinding = @"RNDFilterPredicateBinding";
RNDBindingName RNDFontBinding = @"RNDFontBinding";
RNDBindingName RNDFontBoldBinding = @"RNDFontBoldBinding";
RNDBindingName RNDFontFamilyNameBinding = @"RNDFontFamilyNameBinding";
RNDBindingName RNDFontItalicBinding = @"RNDFontItalicBinding";
RNDBindingName RNDFontNameBinding = @"RNDFontNameBinding";
RNDBindingName RNDFontSizeBinding = @"RNDFontSizeBinding";
RNDBindingName RNDHeaderTitleBinding = @"RNDHeaderTitleBinding";
RNDBindingName RNDHiddenBinding = @"RNDHiddenBinding";
RNDBindingName RNDImageBinding = @"RNDImageBinding";
RNDBindingName RNDIncludedKeysBinding = @"RNDIncludedKeysBinding";
RNDBindingName RNDInitialKeyBinding = @"RNDInitialKeyBinding";
RNDBindingName RNDInitialValueBinding = @"RNDInitialValueBinding";
RNDBindingName RNDIsIndeterminateBinding = @"RNDIsIndeterminateBinding";
RNDBindingName RNDLabelBinding = @"RNDLabelBinding";
RNDBindingName RNDLocalizedKeyDictionaryBinding = @"RNDLocalizedKeyDictionaryBinding";
RNDBindingName RNDManagedObjectContextBinding = @"RNDManagedObjectContextBinding";
RNDBindingName RNDMaximumRecentsBinding = @"RNDMaximumRecentsBinding";
RNDBindingName RNDMaxValueBinding = @"RNDMaxValueBinding";
RNDBindingName RNDMaxWidthBinding = @"RNDMaxWidthBinding";
RNDBindingName RNDMinValueBinding = @"RNDMinValueBinding";
RNDBindingName RNDMinWidthBinding = @"RNDMinWidthBinding";
RNDBindingName RNDMixedStateImageBinding = @"RNDMixedStateImageBinding";
RNDBindingName RNDOffStateImageBinding = @"RNDOffStateImageBinding";
RNDBindingName RNDOnStateImageBinding = @"RNDOnStateImageBinding";
RNDBindingName RNDPositioningRectBinding = @"RNDPositioningRectBinding";
RNDBindingName RNDPredicateBinding = @"RNDPredicateBinding";
RNDBindingName RNDRecentSearchesBinding = @"RNDRecentSearchesBinding";
RNDBindingName RNDRepresentedFilenameBinding = @"RNDRepresentedFilenameBinding";
RNDBindingName RNDRowHeightBinding = @"RNDRowHeightBinding";
RNDBindingName RNDSelectedIdentifierBinding = @"RNDSelectedIdentifierBinding";
RNDBindingName RNDSelectedIndexBinding = @"RNDSelectedIndexBinding";
RNDBindingName RNDSelectedLabelBinding = @"RNDSelectedLabelBinding";
RNDBindingName RNDSelectedObjectBinding = @"RNDSelectedObjectBinding";
RNDBindingName RNDSelectedObjectsBinding = @"RNDSelectedObjectsBinding";
RNDBindingName RNDSelectedTagBinding = @"RNDSelectedTagBinding";
RNDBindingName RNDSelectedValueBinding = @"RNDSelectedValueBinding";
RNDBindingName RNDSelectedValuesBinding = @"RNDSelectedValuesBinding";
RNDBindingName RNDSelectionIndexesBinding = @"RNDSelectionIndexesBinding";
RNDBindingName RNDSelectionIndexPathsBinding = @"RNDSelectionIndexPathsBinding";
RNDBindingName RNDSortDescriptorsBinding = @"RNDSortDescriptorsBinding";
RNDBindingName RNDTargetBinding = @"RNDTargetBinding";
RNDBindingName RNDTextColorBinding = @"RNDTextColorBinding";
RNDBindingName RNDTitleBinding = @"RNDTitleBinding";
RNDBindingName RNDToolTipBinding = @"RNDToolTipBinding";
RNDBindingName RNDTransparentBinding = @"RNDTransparentBinding";
RNDBindingName RNDValueBinding = @"RNDValueBinding";
RNDBindingName RNDValuePathBinding = @"RNDValuePathBinding";
RNDBindingName RNDValueURLBinding = @"RNDValueURLBinding";
RNDBindingName RNDVisibleBinding = @"RNDVisibleBinding";
RNDBindingName RNDWarningValueBinding = @"RNDWarningValueBinding";
RNDBindingName RNDWidthBinding = @"RNDWidthBinding";

// constants for binding options
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
