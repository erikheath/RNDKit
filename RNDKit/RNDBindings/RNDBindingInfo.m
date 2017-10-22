//
//  RNDBindingInfo.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindingInfo.h"

@interface RNDBindingInfo()

@property (class, readonly, nullable) NSDictionary<NSString *, id> * standardBindingsInfo;
@property (class, readonly, nonnull) NSMutableDictionary<RNDBindingName, RNDBindingInfo *> * constructedBindingsInfo;

@property (readwrite, nullable) NSArray<NSAttributeDescription *> *bindingOptionsInfo;
@property (readwrite, nonnull) RNDBindingType bindingType;
@property (readwrite, nonnull) RNDBindingName bindingName;
@property (readwrite) NSAttributeType bindingValueType;
@property (readwrite, assign, nullable) Class bindingValueClass;
@property (readwrite, nullable) NSArray<RNDBindingName> *excludedBindingsWhenActive;
@property (readwrite, nullable) NSArray<RNDBindingName> *requiredBindingsWhenActive;
@property (readwrite, nonnull) NSString *bindingKey;
@property (readwrite, nullable) NSDictionary<RNDBindingMarker, id> *defaultPlaceholders;

@end

@implementation RNDBindingInfo

static NSDictionary * _standardBindingsInfo;
static NSMutableDictionary *_constructedBindingsInfo;

+ (void)initialize {
    [super initialize];
    _standardBindingsInfo = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"RNDKeyValueBindingUI" withExtension:@"plist"]];
    _constructedBindingsInfo = [[NSMutableDictionary alloc] init];
}

+ (NSDictionary<NSString *, id> *)standardBindingsInfo {
    return _standardBindingsInfo;
}

+ (NSMutableDictionary<RNDBindingName, RNDBindingInfo *> *)constructedBindingsInfo {
    return _constructedBindingsInfo;
}

+ (NSArray<NSString *> *)RNDBindingNames {
    return [self.standardBindingsInfo[RNDBindingInfoNameKey] allKeys];
}
+ (NSArray<NSString *> *)RNDBindingOptions {
    return [self.standardBindingsInfo[RNDBindingInfoOptionsKey] allKeys];
}
+ (NSArray<NSAttributeDescription *> *)bindingOptionsInfoForBindingName:(RNDBindingName)bindingName {
    return [[self bindingInfoForBindingName:bindingName] bindingOptionsInfo];
}

+ (RNDBindingInfo *)bindingInfoForBindingName:(RNDBindingName)bindingName {
    @synchronized(self) {
        if ([self constructedBindingsInfo][bindingName] == nil) {
            // This is done once for a given binding name and then stored, making subsequent requests much faster.
            NSMutableDictionary *infoDictionary = [NSMutableDictionary dictionaryWithDictionary:[self standardBindingsInfo][RNDBindingInfoNameKey][bindingName]];
            RNDBindingInfo *binding = [RNDBindingInfo new];
            
            // Set the basic properties of the binding
            binding.bindingName = (RNDBindingName)bindingName;
            binding.bindingType = (RNDBindingType)infoDictionary[RNDBindingInfoTypeKey];
            binding.bindingValueType = (NSAttributeType)[self valueTypeForBindingValueType:infoDictionary[RNDBindingInfoValueTypeKey]];
            binding.bindingValueClass = binding.bindingValueType == NSObjectIDAttributeType ? NSClassFromString(infoDictionary[RNDBindingInfoValueClassKey]) : nil ;
            binding.excludedBindingsWhenActive = (NSArray<RNDBindingName> *)[infoDictionary[RNDBindingInfoExclusionsKey] copy];
            binding.requiredBindingsWhenActive = (NSArray<RNDBindingName> *)[infoDictionary[RNDBindingInfoRequirementsKey] copy];
            binding.bindingKey = [self bindingKeyForBindingName:binding.bindingName];
            binding.defaultPlaceholders = [[NSDictionary alloc] init];
            
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

+ (NSString *)bindingKeyForBindingName:(NSString *)bindingName {
    NSError *error = nil;
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"RND(.*)BindingName" options:0 error:&error];
    NSTextCheckingResult *result = [expression firstMatchInString:bindingName options:NSMatchingAnchored range:NSMakeRange(0, bindingName.length)];
    NSString *bindingKey = [bindingName substringWithRange:[result rangeAtIndex:1]];
    NSString *prefix = [[bindingKey substringWithRange:NSMakeRange(0, 1)] lowercaseString];
    return [bindingKey stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:prefix];
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

+ (void)setDefaultPlaceholder:(id)placeholder forMarker:(RNDBindingMarker)marker withBinding:(RNDBindingName)bindingName {
    RNDBindingInfo *binding = [self bindingInfoForBindingName:bindingName];
    NSMutableDictionary *bindingPlaceholders = binding.defaultPlaceholders != nil ? [NSMutableDictionary dictionaryWithDictionary: binding.defaultPlaceholders] : [[NSMutableDictionary alloc] initWithCapacity:3];
    if (placeholder == nil) {
        [bindingPlaceholders removeObjectForKey:marker];
    } else {
        [bindingPlaceholders setObject:placeholder forKey:marker];
    }
    binding.defaultPlaceholders = [NSDictionary dictionaryWithDictionary:bindingPlaceholders];
}

+ (id)defaultPlaceholderForMarker:(RNDBindingMarker)marker withBinding:(RNDBindingName)bindingName {
    RNDBindingInfo *binding = [self bindingInfoForBindingName:bindingName];
    return binding.defaultPlaceholders[marker];
}


@end
