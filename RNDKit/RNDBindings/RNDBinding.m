//
//  RNDBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinding.h"
#import "RNDBinder.h"
#import "RNDBindingAdaptor.h"

@interface RNDBinding ()

@property (strong, nonnull, readwrite) id observedObject;
@property (strong, nonnull, readwrite) NSString * observedKeyPath;
@property (strong, nonnull, readwrite) NSDictionary<RNDBindingOption, id> *options;
@property (readwrite) BOOL isBound;

@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;

@end

@implementation RNDBinding

#pragma mark - Properties

@synthesize observedObject = _observedObject;
@synthesize observedKeyPath = _observedKeyPath;
@synthesize options = _options;
@synthesize binder = _binder;
@synthesize isBound = _isBound;
@synthesize syncQueue = _syncQueue;

- (RNDBindingName _Nonnull)name {
    return self.binder.bindingInfo.bindingName;
}

#pragma mark - Object Lifecycle

+ (instancetype)bindingForBinder:(RNDBinder *)binder withObserved:(id)object keyPath:(NSString *)keyPath options:(NSDictionary<RNDBindingOption,id> *)options {
    return [[RNDBinding alloc] initWithBinder:binder observed:object keyPath:keyPath options:options];
}

- (instancetype)init {
    return nil;
}

- (instancetype)initWithBinder:(RNDBinder *)binder observed:(id)object keyPath:(NSString *)keyPath options:(NSDictionary<RNDBindingOption,id> *)options {
    
    if ((self = [super init]) == nil) {
        // This is a program error and should never happen.
    }
    
    _binder = binder;
    _observedObject = object;
    _observedKeyPath = keyPath;
    _isBound = NO;
    _syncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableDictionary *optionsDictionary = [NSMutableDictionary dictionaryWithDictionary:options];
    NSArray *keys = [self.binder.bindingInfo.defaultPlaceholders allKeys];
    for (RNDBindingInfoKey key in keys) {
        if (optionsDictionary[key] == nil) {
            [optionsDictionary setValue:self.binder.bindingInfo.defaultPlaceholders[key] forKey:key];
        }
    }
    _options = [NSDictionary dictionaryWithDictionary:optionsDictionary];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init]) != nil) {
        // TODO: Add observed object retrieval mechanism
        _observedKeyPath = [aDecoder decodeObjectForKey:@"observedKeyPath"];
        _options = [aDecoder decodeObjectForKey:@"options"];
        _isBound = NO;
        _syncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_observedKeyPath forKey:@"observedKeyPath"];
    [aCoder encodeObject:_options forKey:@"options"];
    // TODO: Add observed object retrieval mechanism

}

- (void)bind {
    dispatch_barrier_sync(_syncQueue, ^{
        
        // The behavior is dependent upon the type.
        RNDBindingType bindingType = self.binder.bindingInfo.bindingType;
        
        if ([bindingType isEqualToString:RNDBindingTypeSimpleValue]) {
            
            // Observe the observing object - this is a read write binding.
            [self.binder.adaptor addObserver:self
                                  forKeyPath:self.binder.bindingInfo.bindingKey
                                     options:NSKeyValueObservingOptionNew
                                     context:nil];
            
            // Observe the controller.
            [self.observedObject addObserver:self
                                  forKeyPath:self.observedKeyPath
                                     options:NSKeyValueObservingOptionNew
                                     context:(__bridge void * _Nullable)(self.name)];
            
        } else if ([bindingType isEqualToString:RNDBindingTypeSimpleValueReadOnly] || [bindingType isEqualToString:RNDBindingTypeMultiValueOR] || [bindingType isEqualToString:RNDBindingTypeMultiValueAND] || [bindingType isEqualToString:RNDBindingTypeMultiValueWithPattern]) {
            
            // Observe the controller - this is a read only binding so there is no need to observe the observing object.
            [self.observedObject addObserver:self
                         forKeyPath:self.observedKeyPath
                            options:NSKeyValueObservingOptionNew
                            context:(__bridge void * _Nullable)(self.name)];

        }
        
        self.isBound = YES;
    });
}

- (void)unbind {
    dispatch_barrier_sync(_syncQueue, ^{

        // The behavior is dependent upon the type.
        RNDBindingType bindingType = self.binder.bindingInfo.bindingType;
        
        if ([bindingType isEqualToString:RNDBindingTypeSimpleValue]) {
            
            // Observe the observing object - this is a read write binding.
            [self.binder.adaptor removeObserver:self
                                     forKeyPath:self.binder.bindingInfo.bindingKey
                                        context:nil];
            
            // Observe the controller.
            [self.observedObject removeObserver:self
                                     forKeyPath:self.observedKeyPath
                                        context:(__bridge void * _Nullable)(self.name)];
            
        } else if ([bindingType isEqualToString:RNDBindingTypeSimpleValueReadOnly] || [bindingType isEqualToString:RNDBindingTypeMultiValueOR] || [bindingType isEqualToString:RNDBindingTypeMultiValueAND] || [bindingType isEqualToString:RNDBindingTypeMultiValueWithPattern]) {
            
            // Observe the controller - this is a read only binding so there is no need to observe the observing object.
            // Observe the controller.
            [self.observedObject removeObserver:self
                                     forKeyPath:self.observedKeyPath
                                        context:(__bridge void * _Nullable)(self.name)];
        }
        
        self.isBound = NO;
    });
}

@end

#pragma mark - Key Value Observation

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([(__bridge RNDBindingName _Nonnull)(context) isKindOfClass: [NSString class]] == NO || [self infoForBinding:(__bridge RNDBindingName _Nonnull)(context)] == nil) {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//
//    // Which object is this? controller or self?
//    if (object == self) {
//        if (change[NSKeyValueChangeNotificationIsPriorKey] != nil) {
//            NSDictionary *binding = [self infoForBinding:(__bridge RNDBindingName _Nonnull)(context)];
//            id<RNDEditor, RNDEditorRegistration> observedObject = binding[RNDBindingInfoObservedObjectKey];
//            if ([[observedObject editorSet] containsObject:self] == NO) {
//                [observedObject objectDidBeginEditing:self];
//            }
//            return;
//        }
//        [self updateObservedValueForKeyPath:keyPath change:change context:context];
//
//    } else if (object == [self infoForBinding:(__bridge RNDBindingName _Nonnull)(context)][RNDBindingInfoObservedObjectKey]) {
//        [self updateBoundObjectValueForKeyPath:keyPath ofObject:object change:change context:(__bridge RNDBindingName)(context)];
//    }
//}
//
//- (void)updateObservedValueForKeyPath:(NSString *)keyPath change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    // Check if the value of the editor is the same as the value of the observed object
//    NSDictionary *binding = [self infoForBinding:(__bridge RNDBindingName _Nonnull)(context)];
//    id observedObject = binding[RNDBindingInfoObservedObjectKey];
//    id observedObjectValue = [observedObject valueForKey:binding[RNDBindingInfoObservedKeyPathKey]];
//    NSString *observedObjectKeyPath = [binding valueForKey:RNDBindingInfoObservedKeyPathKey];
//    id currentValue = [self valueForKeyPath:keyPath];
//    NSAttributeType bindingValueType = NSUndefinedAttributeType;
//    if (binding[RNDBindingInfoOptionsKey][RNDValueTransformerBindingOption] != nil) {
//        NSValueTransformer *transformer = (NSValueTransformer *)binding[RNDBindingInfoOptionsKey][RNDValueTransformerBindingOption];
//        observedObjectValue = [transformer transformedValue:observedObjectValue];
//        bindingValueType = [self bindingValueTypeForObject:observedObjectValue];
//    }
//    // If they're the same, then don't do anything and exit the update method.
//    if ([self boundAttributeValue:[self valueForKeyPath:keyPath] isEqualToObjectValue:observedObjectValue forBindingAttribute:bindingValueType]) return;
//
//    if ([binding[RNDBindingInfoOptionsKey][RNDValidatesImmediatelyBindingOption] boolValue] == YES) {
//        NSError *error = nil;
//        BOOL isValid = [observedObject validateValue:&currentValue forKeyPath:observedObjectKeyPath error:&error];
//        if (isValid == NO) {
//            // Notify the delegate of the validation failure and pass the error to it.
//        }
//    }
//
//    // Change the value on the controller using set value for key path.
//    [observedObject setValue:currentValue forKeyPath:observedObjectKeyPath];
//
//}
//
//- (void)updateBoundObjectValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(RNDBindingName)bindingName {
//    // Get the key of self
//    NSString *bindingKey = [[RNDBindingInfo bindingInfoForBindingName:bindingName] bindingKey];
//    // Get the value
//    id objectValue = [object valueForKeyPath:keyPath];
//    NSAttributeType bindingValueType = [[RNDBindingInfo bindingInfoForBindingName:bindingName] bindingValueType];
//    // Transform the value if necessary
//    if ([self infoForBinding:bindingName][RNDBindingInfoOptionsKey][RNDValueTransformerBindingOption] != nil) {
//        NSValueTransformer *transformer = (NSValueTransformer *)[self infoForBinding:bindingName][RNDValueTransformerBindingOption];
//        objectValue = [transformer transformedValue:objectValue];
//        bindingValueType = [self bindingValueTypeForObject:objectValue];
//    }
//    // If they're the same, then don't do anything and exit the update method.
//    if ([self boundAttributeValue:[self valueForKeyPath:bindingKey] isEqualToObjectValue:objectValue forBindingAttribute:bindingValueType]) return;
//    // Otherwise, set the new value;
//    [self setValue:objectValue forKey:bindingKey];
//}
//
//- (NSAttributeType)bindingValueTypeForObject:(id)object {
//    NSAttributeType objectType = NSUndefinedAttributeType;
//    if (object == nil) {
//        objectType = NSUndefinedAttributeType;
//    } else if ([object isKindOfClass:[NSString class]]) {
//        objectType = NSStringAttributeType;
//    } else if ([object isKindOfClass:[NSNumber class]]) {
//        NSString *encodedType = [NSString stringWithCString:[(NSNumber *)object objCType] encoding:NSUTF8StringEncoding];
//        if ([encodedType isEqualToString:@"B"]) {
//            objectType = NSBooleanAttributeType;
//        } else if ([encodedType isEqualToString:@"i"]||[encodedType isEqualToString:@"I"]) {
//            objectType = NSInteger32AttributeType;
//        } else if ([encodedType isEqualToString:@"s"]||[encodedType isEqualToString:@"S"]) {
//            objectType = NSInteger16AttributeType;
//        } else if ([encodedType isEqualToString:@"l"]||[encodedType isEqualToString:@"L"]||[encodedType isEqualToString:@"q"]||[encodedType isEqualToString:@"Q"]) {
//            objectType = NSInteger64AttributeType;
//        } else if ([encodedType isEqualToString:@"f"]) {
//            objectType = NSFloatAttributeType;
//        } else if ([encodedType isEqualToString:@"d"]) {
//            objectType = NSDoubleAttributeType;
//        } else {
//            objectType = NSObjectIDAttributeType;
//        }
//    } else if ([object isKindOfClass:[NSDate class]]) {
//        objectType = NSDateAttributeType;
//    } else if ([object isKindOfClass:[NSData class]]) {
//        objectType = NSBinaryDataAttributeType;
//    } else if ([object isKindOfClass:[NSURL class]]) {
//        objectType = NSURIAttributeType;
//    } else if ([object isKindOfClass:[NSDecimalNumber class]]) {
//        objectType = NSDecimalAttributeType;
//    } else if ([object isKindOfClass:[NSUUID class]]) {
//        objectType = NSUUIDAttributeType;
//    } else {
//        objectType = NSObjectIDAttributeType;
//    }
//    return objectType;
//}
//
//- (BOOL)boundAttributeValue:(id)attributeValue isEqualToObjectValue:(id)objectValue forBindingAttribute:(NSAttributeType)bindingType {
//    // Figure out if the controller value is equal to the intrinsic control value. If so, do nothing. If not, commit the editing??
//    // Determine the type of equality to invoke and make sure to test for nil so there are no throws.
//    BOOL isEqualValue = NO;
//    switch (bindingType) {
//        case NSStringAttributeType:
//        {
//            isEqualValue = [attributeValue isEqualToString:objectValue];
//            break;
//        }
//        case NSURIAttributeType:
//        {
//            isEqualValue = [(NSURL *)attributeValue isEqual:objectValue];
//            break;
//        }
//        case NSUUIDAttributeType:
//        {
//            isEqualValue = [(NSUUID *)attributeValue isEqual:objectValue];
//            break;
//        }
//        case NSDateAttributeType:
//        {
//            isEqualValue = [(NSDate *)attributeValue isEqualToDate:objectValue];
//            break;
//        }
//        case NSObjectIDAttributeType:
//        {
//            isEqualValue = [attributeValue isEqual:objectValue];
//            break;
//        }
//        case NSTransformableAttributeType:
//        {
//            break;
//        }
//        case NSBooleanAttributeType:
//        {
//            isEqualValue = ([attributeValue boolValue] == [objectValue boolValue]);
//            break;
//        }
//        case NSBinaryDataAttributeType:
//        {
//            isEqualValue = [(NSData *)attributeValue isEqualToData:objectValue];
//            break;
//        }
//        case NSFloatAttributeType:
//        {
//            isEqualValue = ([attributeValue floatValue] == [objectValue floatValue]);
//            break;
//        }
//        case NSDoubleAttributeType:
//        {
//            isEqualValue = ([attributeValue doubleValue] == [objectValue doubleValue]);
//            break;
//        }
//        case NSDecimalAttributeType:
//        {
//            isEqualValue = [(NSDecimalNumber *)attributeValue isEqualToNumber:objectValue];
//            break;
//        }
//        case NSInteger16AttributeType:
//        {
//            isEqualValue = ([attributeValue intValue] == [objectValue intValue]);
//            break;
//        }
//        case NSInteger32AttributeType:
//        {
//            isEqualValue = ([attributeValue integerValue] == [objectValue integerValue]);
//            break;
//        }
//        case NSInteger64AttributeType:
//        {
//            isEqualValue = ([attributeValue longLongValue] == [objectValue longLongValue]);
//            break;
//        }
//        case NSUndefinedAttributeType:
//        {
//            break;
//        }
//        default:
//            break;
//    }
//    return isEqualValue;
//}

