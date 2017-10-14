//
//  RNDBindings.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/11/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindings.h"

@interface RNDBinding()

@property (class, readonly, nullable) NSDictionary<NSString *, id> * standardBindingsInfo;
@property (class, readonly, nonnull) NSMutableDictionary<RNDBindingName, RNDBinding *> * constructedBindingsInfo;

@property (readwrite, nullable) NSArray<NSAttributeDescription *> *bindingOptionsInfo;
@property (readwrite, nonnull) RNDBindingType bindingType;
@property (readwrite, nonnull) RNDBindingName bindingName;
@property (readwrite) NSAttributeType bindingValueType;
@property (readwrite, assign, nullable) Class bindingValueClass;
@property (readwrite, nullable) NSArray<RNDBindingName> *excludedBindingsWhenActive;
@property (readwrite, nullable) NSArray<RNDBindingName> *requiredBindingsWhenActive;


@end

@implementation RNDBinding

static NSDictionary * _standardBindingsInfo;
static NSMutableDictionary *_constructedBindingsInfo;

+ (void)initialize {
    [super initialize];
    _standardBindingsInfo = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"RNDKeyValueBindingUI" withExtension:@"plist"]];
    _constructedBindingsInfo = [[NSMutableDictionary alloc] init];
}

+ (NSDictionary<NSString *, id> *)standardBindingsInfo {
    return _standardBindingsInfo;
}

+ (NSMutableDictionary<RNDBindingName, RNDBinding *> *)constructedBindingsInfo {
    return _constructedBindingsInfo;
}

+ (NSArray<NSString *> *)RNDBindingNames {
    return [self.standardBindingsInfo[RNDBindingInfoNamesKey] allKeys];
}
+ (NSArray<NSString *> *)RNDBindingOptions {
    return [self.standardBindingsInfo[RNDBindingInfoOptionsKey] allKeys];
}
+ (NSArray<NSAttributeDescription *> *)bindingOptionsInfoForBindingName:(RNDBindingName)bindingName {
    return [[self bindingInfoForBindingName:bindingName] bindingOptionsInfo];
}

+ (RNDBinding *)bindingInfoForBindingName:(RNDBindingName)bindingName {
    @synchronized(self) {
        if ([self constructedBindingsInfo][bindingName] == nil) {
            // This is done once for a given binding name and then stored, making subsequent requests much faster.
            NSMutableDictionary *infoDictionary = [NSMutableDictionary dictionaryWithDictionary:[self standardBindingsInfo][RNDBindingInfoNamesKey][bindingName]];
            RNDBinding *binding = [RNDBinding new];
            
            // Set the basic properties of the binding
            binding.bindingName = (RNDBindingName)bindingName;
            binding.bindingType = (RNDBindingType)infoDictionary[RNDBindingInfoTypeKey];
            binding.bindingValueType = (NSAttributeType)[self valueTypeForBindingValueType:infoDictionary[RNDBindingInfoValueTypeKey]];
            binding.bindingValueClass = binding.bindingValueType == NSObjectIDAttributeType ? NSClassFromString(infoDictionary[RNDBindingInfoValueClassKey]) : nil ;
            binding.excludedBindingsWhenActive = (NSArray<RNDBindingName> *)[infoDictionary[RNDBindingInfoExclusionsKey] copy];
            binding.requiredBindingsWhenActive = (NSArray<RNDBindingName> *)[infoDictionary[RNDBindingInfoRequirementsKey] copy];
            
            // Set the options
            NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
            for (RNDBindingOption optionsKey in infoDictionary[RNDBindingInfoOptionsKey]) {
                NSAttributeDescription *optionDescription = [NSAttributeDescription new];
                NSDictionary *optionDescriptionDictionary = [self standardBindingsInfo][RNDBindingInfoOptionsKey][optionsKey];
                optionDescription.name = optionsKey;
                optionDescription.attributeType = [self valueTypeForBindingValueType:optionDescriptionDictionary[RNDBindingInfoValueTypeKey]];
                optionDescription.defaultValue = [self value:optionDescriptionDictionary[RNDBindingInfoDefaultValueKey] forType:optionDescription.attributeType];
                [optionsArray addObject:optionDescription];
            }
            binding.bindingOptionsInfo = [NSArray arrayWithArray:optionsArray];
            
            // Add to the list
            [[self constructedBindingsInfo] setObject:binding forKey:bindingName];
            
        }
    }
    return [self constructedBindingsInfo][bindingName];
}

+ (NSAttributeType)valueTypeForBindingValueType:(RNDBindingValueType)bindingValueType {
    
    NSAttributeType attType;
    
    if (RNDBindingValueBooleanType) {
        attType = NSBooleanAttributeType;
    } else if (RNDBindingValueURLType) {
        attType = NSURIAttributeType;
    } else if (RNDBindingValueDateType) {
        attType = NSDateAttributeType;
    } else if (RNDBindingValueUUIDType) {
        attType = NSUUIDAttributeType;
    } else if (RNDBindingValueFloatType) {
        attType = NSFloatAttributeType;
    } else if (RNDBindingValueInt16Type) {
        attType = NSInteger16AttributeType;
    } else if (RNDBindingValueInt32Type) {
        attType = NSInteger32AttributeType;
    } else if (RNDBindingValueInt64Type) {
        attType = NSInteger64AttributeType;
    } else if (RNDBindingValueBinaryType) {
        attType = NSBinaryDataAttributeType;
    } else if (RNDBindingValueDoubleType) {
        attType = NSDoubleAttributeType;
    } else if (RNDBindingValueStringType) {
        attType = NSStringAttributeType;
    } else if (RNDBindingValueDecimalType) {
        attType = NSDecimalAttributeType;
    } else if (RNDBindingValueObjectIDType) {
        attType = NSObjectIDAttributeType;
    } else if (RNDBindingValueTransformableType) {
        attType = NSTransformableAttributeType;
    } else {
        attType = NSUndefinedAttributeType;
    }
    
    return attType;
}

+ (id)value:(id)value forBindingValueType:(RNDBindingValueType)bindingValueType {
    
    return [self value:value forType:[self valueTypeForBindingValueType:bindingValueType]];
}

+ (id)value:(id)value forType:(NSAttributeType)attributeType {
    
    id transformedValue;
    
    switch (attributeType) {
        case NSUndefinedAttributeType:
        {
            transformedValue = nil;
            break;
        }
        
        case NSTransformableAttributeType:
        {
            transformedValue = value;
            break;
        }

        case NSObjectIDAttributeType:
        {
            transformedValue = NSClassFromString(value);
            break;
        }

        case NSDecimalAttributeType:
        {
            transformedValue = [NSDecimalNumber decimalNumberWithString:value];
            break;
        }

        case NSStringAttributeType:
        {
            transformedValue = value;
            break;
        }

        case NSInteger16AttributeType:
        {
            transformedValue = [NSNumber numberWithShort: (int16_t)[(NSString *)value intValue]];
            break;
        }

        case NSInteger32AttributeType:
        {
            transformedValue = [NSNumber numberWithInt: (int32_t)[(NSString *)value integerValue]];
            break;
        }

        case NSInteger64AttributeType:
        {
            transformedValue = [NSNumber numberWithLongLong: (int64_t)[(NSString *)value longLongValue]];
            break;
        }

        case NSFloatAttributeType:
        {
            transformedValue = [NSNumber numberWithFloat: [(NSString *)value floatValue]];
            break;
        }

        case NSDoubleAttributeType:
        {
            transformedValue = [NSNumber numberWithDouble: [(NSString *)value doubleValue]];
            break;
        }

        case NSDateAttributeType:
        {
            NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
            transformedValue = [formatter dateFromString:value];
            break;
        }

        case NSURIAttributeType:
        {
            transformedValue = [NSURL URLWithString:value];
            break;
        }

        case NSBooleanAttributeType:
        {
            transformedValue = [NSNumber numberWithBool: [(NSString *)value boolValue]];
            break;
        }
            
        case NSUUIDAttributeType:
        {
            transformedValue = [[NSUUID alloc] initWithUUIDString:value];
            break;
        }

        case NSBinaryDataAttributeType:
        {
            transformedValue = [(NSString *)value dataUsingEncoding:NSUTF8StringEncoding];
            break;
        }

        default:
            break;
    }
    
    return transformedValue;
}


@end

#pragma mark - RNDBindingType Definitions
RNDBindingType RNDBindingTypeSimpleValue = @"RNDBindingTypeSimpleValue";
RNDBindingType RNDBindingTypeSimpleValueReadOnly = @"RNDBindingTypeSimpleValueReadOnly";
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
