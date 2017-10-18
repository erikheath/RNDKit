//
//  UIView+RNDBindings.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/11/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "UIView+RNDBindings.h"
#import <objc/runtime.h>

@implementation UIView (RNDBindings)

#pragma mark - Key Value Binding Creation Class Methods

// Adds a binding name to the internal mutable set. Read bindings using exposedBindings.
+ (void)exposeBinding:(nonnull RNDBindingName)binding {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self class] initializeBindings];
    });
    NSMutableSet *bindingSet = objc_getAssociatedObject([self class], @selector(exposedBindings));
    [bindingSet addObject:binding];
}

// Creates the mutable set that keeps track of all of the bindings: default, and those that are added at runtime.
+ (void)initializeBindings {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableSet<RNDBindingName> *bindingSet;
        if (objc_getAssociatedObject(self, @selector(exposedBindings)) == nil) {
            // Add the bindings for UIView. this should be done once in a thread safe manner.
            objc_setAssociatedObject(self, @selector(exposedBindings), [[NSMutableSet alloc] init], OBJC_ASSOCIATION_RETAIN);
        }
        bindingSet = objc_getAssociatedObject(self, @selector(exposedBindings));
        [bindingSet addObjectsFromArray:[self defaultBindings]];

        if ([[self superclass] respondsToSelector:@selector(initializeBindings)] == YES) {
            [[self superclass] initializeBindings];
        }
    });
}

// Returns the default bindings assigned to the class
+ (NSArray<RNDBindingName> *)defaultBindings {
    return @[RNDHiddenBindingName];
}

// Returns the binding names exposed by the current class.
+ (NSArray<RNDBindingName>*)exposedBindings {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initializeBindings];
    });
    return [(NSMutableSet<RNDBindingName>*)objc_getAssociatedObject([self class], @selector(exposedBindings)) allObjects];
}

// Returns the binding names exposed by the curreny class and all of its superclasses.
+ (NSArray *)allExposedBindings {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initializeBindings];
    });
    
    NSMutableArray *allBindings = [NSMutableArray arrayWithArray:self.exposedBindings];
    if ([[self superclass] respondsToSelector:@selector(allExposedBindings)]) {
        [allBindings addObjectsFromArray:[[self superclass] allExposedBindings]];
    }
    
    return [NSArray arrayWithArray:allBindings];
}

#pragma mark - Key Value Binding Creation Instance Methods

- (void)bind:(nonnull RNDBindingName)bindingName toObject:(nonnull id)observable withKeyPath:(nonnull NSString *)keyPath options:(nullable NSDictionary<RNDBindingOption,id> *)options {
    NSMutableDictionary<RNDBindingName, NSMutableDictionary *> __block *bindingsDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (objc_getAssociatedObject(self, @selector(infoForBinding:)) == nil) {
            objc_setAssociatedObject(self, @selector(infoForBinding:), [[NSMutableDictionary alloc] init], OBJC_ASSOCIATION_RETAIN);
        }
    });
    bindingsDictionary = objc_getAssociatedObject(self, @selector(infoForBinding:));
    
    // When a binding is set up from a category that does not have source code access, the object must observe itself to detect any changes and pass them on in addition to observing changes in the controller. This means it must maintain a list of bindings that will be removed when the object is deallocated that includes both the controller and the object itself.
    RNDBinding *bindingInfo = [RNDBinding bindingInfoForBindingName:bindingName];
    NSMutableDictionary *binding = [[NSMutableDictionary alloc] init];
    
    [binding setObject:observable forKey:RNDBindingInfoObservedObjectKey];
    [binding setObject:keyPath forKey:RNDBindingInfoObservedKeyPathKey];
    NSMutableDictionary *bindingOptions = [[NSMutableDictionary alloc] init];
    if (bindingInfo.defaultPlaceholders != nil) [bindingOptions addEntriesFromDictionary:bindingInfo.defaultPlaceholders];
    if (options != nil) [bindingOptions addEntriesFromDictionary:options];
    if ([bindingOptions count] > 0) [binding setObject:bindingOptions forKey:RNDBindingInfoOptionsKey];
    [bindingsDictionary setObject:binding forKey:bindingName];
    
    // Observe the self
    [self addObserver:self forKeyPath:bindingInfo.bindingKey options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(bindingName)];

    // Observe the controller
    [observable addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(bindingName)];
    
}

- (void)unbind:(nonnull RNDBindingName)bindingName {
    NSMutableDictionary<RNDBindingName, NSMutableDictionary *> *bindingsDictionary = objc_getAssociatedObject(self, @selector(infoForBinding:));
    NSMutableDictionary *binding = [bindingsDictionary objectForKey:bindingName];
    [binding[RNDBindingInfoObservedObjectKey] removeObserver:self forKeyPath:binding[RNDBindingInfoObservedKeyPathKey] context:(__bridge void * _Nullable)(bindingName)];
    [self removeObserver:self forKeyPath:[[RNDBinding bindingInfoForBindingName:bindingName] bindingKey] context:(__bridge void * _Nullable)(bindingName)];
    [bindingsDictionary removeObjectForKey:bindingName];
}


/* Returns a dictionary with information about a binding or nil if the binding is not bound (this is mostly for use by subclasses which want to analyze the existing bindings of an object) - the dictionary contains three key/value pairs: NSObservedObjectKey: object bound, NSObservedKeyPathKey: key path bound, NSOptionsKey: dictionary with the options and their values for the bindings.
 */

- (nullable NSDictionary<RNDBindingInfoKey,id> *)infoForBinding:(nonnull RNDBindingName)bindingName {
    return objc_getAssociatedObject(self, @selector(infoForBinding:))[bindingName];
}

/* Returns an array of NSAttributeDescriptions that describe the options for aBinding. The descriptions are used by Interface Builder to build the options editor UI of the bindings inspector. Each binding may have multiple options. The options and attribute descriptions have 3 properties in common:
 
 - The option "name" is derived from the attribute description name.
 
 - The type of UI built for the option is based on the attribute type.
 
 - The default value shown in the options editor comes from the attribute description's defaultValue.*/

- (nonnull NSArray<NSAttributeDescription *> *)optionDescriptionsForBinding:(nonnull RNDBindingName)bindingName {
    return [RNDBinding bindingOptionsInfoForBindingName:bindingName];
}

// Returns the class of the value expected by the binding.
- (nullable Class)valueClassForBinding:(nonnull RNDBindingName)bindingName {
    return [[RNDBinding bindingInfoForBindingName:bindingName] bindingValueClass];
}

- (nullable id)placeholderForMarker:(nonnull RNDBindingMarker)marker withBinding:(nonnull RNDBindingName)bindingName {
    NSDictionary *bindingsDictionary = objc_getAssociatedObject(self, @selector(infoForBinding:));
    return bindingsDictionary[bindingName][RNDBindingInfoOptionsKey][marker];
}

- (void)setplaceholder:(nullable id)placeholder forMarker:(nonnull RNDBindingMarker)marker withBinding:(nonnull RNDBindingName)bindingName {
    NSDictionary *bindingsDictionary = objc_getAssociatedObject(self, @selector(infoForBinding:));
    NSDictionary *binding = bindingsDictionary[bindingName];
    NSMutableDictionary *bindingOptions = binding[RNDBindingInfoOptionsKey];
    if (placeholder == nil) {
        [bindingOptions removeObjectForKey:marker];
    } else {
        [bindingOptions setObject:placeholder forKey:marker];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([(__bridge RNDBindingName _Nonnull)(context) isKindOfClass: [NSString class]] == NO || [self infoForBinding:(__bridge RNDBindingName _Nonnull)(context)] == nil) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    // Which object is this? controller or self?
    if (object == self) {
        [self updateObservedValueForKeyPath:keyPath change:change context:context];
    } else if (object == [self infoForBinding:(__bridge RNDBindingName _Nonnull)(context)][RNDBindingInfoObservedObjectKey]) {
        [self updateBoundObjectValueForKeyPath:keyPath ofObject:object change:change context:(__bridge RNDBindingName)(context)];
    }
}

- (void)updateObservedValueForKeyPath:(NSString *)keyPath change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    // Check if the value of the editor is the same as the value of the observed object
    NSDictionary *binding = [self infoForBinding:(__bridge RNDBindingName _Nonnull)(context)];
    id observedObject = binding[RNDBindingInfoObservedObjectKey];
    id observedObjectValue = [observedObject valueForKey:binding[RNDBindingInfoObservedKeyPathKey]];
    NSString *observedObjectKeyPath = [binding valueForKey:RNDBindingInfoObservedKeyPathKey];
    id currentValue = [self valueForKeyPath:keyPath];
    NSAttributeType bindingValueType = NSUndefinedAttributeType;
    if (binding[RNDBindingInfoOptionsKey][RNDValueTransformerBindingOption] != nil) {
        NSValueTransformer *transformer = (NSValueTransformer *)binding[RNDBindingInfoOptionsKey][RNDValueTransformerBindingOption];
        observedObjectValue = [transformer transformedValue:observedObjectValue];
        bindingValueType = [self bindingValueTypeForObject:observedObjectValue];
    }
    // If they're the same, then don't do anything and exit the update method.
    if ([self boundAttributeValue:[self valueForKeyPath:keyPath] isEqualToObjectValue:observedObjectValue forBindingAttribute:bindingValueType]) return;
    
    if ([binding[RNDBindingInfoOptionsKey][RNDValidatesImmediatelyBindingOption] boolValue] == YES) {
        NSError *error = nil;
        BOOL isValid = [observedObject validateValue:&currentValue forKeyPath:observedObjectKeyPath error:&error];
        if (isValid == NO) {
            // Notify the delegate of the validation failure and pass the error to it.
        }
    }
    
    // Change the value on the controller using set value for key path.
    [observedObject setValue:currentValue forKeyPath:observedObjectKeyPath];

}

- (void)updateBoundObjectValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(RNDBindingName)bindingName {
    // Get the key of self
    NSString *bindingKey = [[RNDBinding bindingInfoForBindingName:bindingName] bindingKey];
    // Get the value
    id objectValue = [object valueForKeyPath:keyPath];
    NSAttributeType bindingValueType = [[RNDBinding bindingInfoForBindingName:bindingName] bindingValueType];
    // Transform the value if necessary
    if ([self infoForBinding:bindingName][RNDBindingInfoOptionsKey][RNDValueTransformerBindingOption] != nil) {
        NSValueTransformer *transformer = (NSValueTransformer *)[self infoForBinding:bindingName][RNDValueTransformerBindingOption];
        objectValue = [transformer transformedValue:objectValue];
        bindingValueType = [self bindingValueTypeForObject:objectValue];
    }
    // If they're the same, then don't do anything and exit the update method.
    if ([self boundAttributeValue:[self valueForKeyPath:bindingKey] isEqualToObjectValue:objectValue forBindingAttribute:bindingValueType]) return;
    // Otherwise, set the new value;
    [self setValue:objectValue forKey:bindingKey];
}

- (NSAttributeType)bindingValueTypeForObject:(id)object {
    NSAttributeType objectType = NSUndefinedAttributeType;
    if (object == nil) {
        objectType = NSUndefinedAttributeType;
    } else if ([object isKindOfClass:[NSString class]]) {
        objectType = NSStringAttributeType;
    } else if ([object isKindOfClass:[NSNumber class]]) {
        NSString *encodedType = [NSString stringWithCString:[(NSNumber *)object objCType] encoding:NSUTF8StringEncoding];
        if ([encodedType isEqualToString:@"B"]) {
            objectType = NSBooleanAttributeType;
        } else if ([encodedType isEqualToString:@"i"]||[encodedType isEqualToString:@"I"]) {
            objectType = NSInteger32AttributeType;
        } else if ([encodedType isEqualToString:@"s"]||[encodedType isEqualToString:@"S"]) {
            objectType = NSInteger16AttributeType;
        } else if ([encodedType isEqualToString:@"l"]||[encodedType isEqualToString:@"L"]||[encodedType isEqualToString:@"q"]||[encodedType isEqualToString:@"Q"]) {
            objectType = NSInteger64AttributeType;
        } else if ([encodedType isEqualToString:@"f"]) {
            objectType = NSFloatAttributeType;
        } else if ([encodedType isEqualToString:@"d"]) {
            objectType = NSDoubleAttributeType;
        } else {
            objectType = NSObjectIDAttributeType;
        }
    } else if ([object isKindOfClass:[NSDate class]]) {
        objectType = NSDateAttributeType;
    } else if ([object isKindOfClass:[NSData class]]) {
        objectType = NSBinaryDataAttributeType;
    } else if ([object isKindOfClass:[NSURL class]]) {
        objectType = NSURIAttributeType;
    } else if ([object isKindOfClass:[NSDecimalNumber class]]) {
        objectType = NSDecimalAttributeType;
    } else if ([object isKindOfClass:[NSUUID class]]) {
        objectType = NSUUIDAttributeType;
    } else {
        objectType = NSObjectIDAttributeType;
    }
    return objectType;
}

- (BOOL)boundAttributeValue:(id)attributeValue isEqualToObjectValue:(id)objectValue forBindingAttribute:(NSAttributeType)bindingType {
    // Figure out if the controller value is equal to the intrinsic control value. If so, do nothing. If not, commit the editing??
    // Determine the type of equality to invoke and make sure to test for nil so there are no throws.
    BOOL isEqualValue = NO;
    switch (bindingType) {
        case NSStringAttributeType:
        {
            isEqualValue = [attributeValue isEqualToString:objectValue];
            break;
        }
        case NSURIAttributeType:
        {
            isEqualValue = [(NSURL *)attributeValue isEqual:objectValue];
            break;
        }
        case NSUUIDAttributeType:
        {
            isEqualValue = [(NSUUID *)attributeValue isEqual:objectValue];
            break;
        }
        case NSDateAttributeType:
        {
            isEqualValue = [(NSDate *)attributeValue isEqualToDate:objectValue];
            break;
        }
        case NSObjectIDAttributeType:
        {
            isEqualValue = [attributeValue isEqual:objectValue];
            break;
        }
        case NSTransformableAttributeType:
        {
            break;
        }
        case NSBooleanAttributeType:
        {
            isEqualValue = ([attributeValue boolValue] == [objectValue boolValue]);
            break;
        }
        case NSBinaryDataAttributeType:
        {
            isEqualValue = [(NSData *)attributeValue isEqualToData:objectValue];
            break;
        }
        case NSFloatAttributeType:
        {
            isEqualValue = ([attributeValue floatValue] == [objectValue floatValue]);
            break;
        }
        case NSDoubleAttributeType:
        {
            isEqualValue = ([attributeValue doubleValue] == [objectValue doubleValue]);
            break;
        }
        case NSDecimalAttributeType:
        {
            isEqualValue = [(NSDecimalNumber *)attributeValue isEqualToNumber:objectValue];
            break;
        }
        case NSInteger16AttributeType:
        {
            isEqualValue = ([attributeValue intValue] == [objectValue intValue]);
            break;
        }
        case NSInteger32AttributeType:
        {
            isEqualValue = ([attributeValue integerValue] == [objectValue integerValue]);
            break;
        }
        case NSInteger64AttributeType:
        {
            isEqualValue = ([attributeValue longLongValue] == [objectValue longLongValue]);
            break;
        }
        case NSUndefinedAttributeType:
        {
            break;
        }
        default:
            break;
    }
    return isEqualValue;
}

#pragma mark - RND Direct Property Access



#pragma mark - RND Editor

// Abstract Implementation.
- (BOOL)commitEditing {
    return NO;
}

// Abstract Implementation.
- (BOOL)commitEditingAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return NO;
}

// Abstract Implementation.
- (void)commitEditingWithDelegate:(nullable id<RNDEditorDelegate>)delegate didCommitSelector:(nullable SEL)didCommitSelector contextInfo:(nullable void *)contextInfo {
    
}

// Abstract Implementation.
- (void)editor:(nonnull id<RNDEditor>)editor didCommit:(BOOL)didCommit contextInfo:(nonnull void *)contextInfo {
    
}

// If this method is called on the object, it must discard it's current editing and get the original value from the controller. Editing works on the intrinsic value of a control. For example, a text field's value is its text, a checkbox is its state, a table has rows, etc. A control can only have one intrinsic value. Subclasses must override this method to reflect the intrinsic value of the control, if there is one.
- (void)discardEditing {
    
}

#pragma mark - RND Editor Registration
- (void)beginEditing:(nonnull id<RNDEditorRegistration>)controller {
    [controller objectDidBeginEditing:self];
}

- (void)endEditing:(nonnull id<RNDEditorRegistration>)controller {
    [controller objectDidEndEditing:self];
}


@end
