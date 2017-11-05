//
//  RNDBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinding.h"
#import "RNDBinder.h"
#import <objc/runtime.h>


@interface RNDBinding ()

@property (strong, nullable, readonly) NSValueTransformer *valueTransformer;
@property (strong, nullable, readonly) NSUUID *syncQueueIdentifier;

@end

@implementation RNDBinding

#pragma mark - Properties
@synthesize observedObject = _observedObject;
@synthesize observedObjectKeyPath = _observedObjectKeyPath;
@synthesize observedObjectBindingIdentifier = _observedObjectBindingIdentifier;
@synthesize monitorsObservedObject = _monitorsObservedObject;

@synthesize binder = _binder;
@synthesize bindingName = _bindingName;

@synthesize isBound = _isBound;

@synthesize nullPlaceholder = _nullPlaceholder;
@synthesize multipleSelectionPlaceholder = _multipleSelectionPlaceholder;
@synthesize notApplicablePlaceholder = _notApplicablePlaceholder;

@synthesize argumentName = _argumentName;
@synthesize valueTransformerName = _valueTransformerName;
@synthesize valueTransformer = _valueTransformer;

@synthesize syncQueue = _syncQueue;

- (id _Nullable)bindingObjectValue {
     id __block objectValue = nil;

    dispatch_sync(_syncQueue, ^{
        
        if (_isBound == NO) {
            return;
        }
        
        id rawObjectValue = [_observedObject valueForKeyPath:_observedObjectKeyPath];
        
        
        if ([rawObjectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
            objectValue = _multipleSelectionPlaceholder != nil ? _multipleSelectionPlaceholder : rawObjectValue;
            return;
        }
        
        if ([rawObjectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
            objectValue = _noSelectionPlaceholder != nil ? _noSelectionPlaceholder : rawObjectValue;
            return;
        }
        
        if ([rawObjectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
            objectValue = _notApplicablePlaceholder != nil ? _notApplicablePlaceholder : rawObjectValue;
            return;
        }
        
        id transformedObjectValue = nil;
        transformedObjectValue = _valueTransformer != nil ? [_valueTransformer transformedValue:rawObjectValue] : rawObjectValue;
        
        if (transformedObjectValue == nil && _nullPlaceholder != nil) {
            objectValue = _nullPlaceholder;
            return;
        } else {
            objectValue = transformedObjectValue;
            return;
        }
    });
    
    return objectValue != [NSNull null] ? objectValue : [NSNull null];;
}

- (void)setBindingObjectValue:(id)bindingObjectValue {
    dispatch_barrier_async(_syncQueue, ^{
        // There may be no actual change, in which case nothing needs to happen.
        if ([self.bindingObjectValue isEqual:bindingObjectValue]) {
            return;
        }
        id transformedValue = nil;
        if(_valueTransformer != nil && [[_valueTransformer class] allowsReverseTransformation] == YES) {
            transformedValue = [_valueTransformer reverseTransformedValue:bindingObjectValue];
        } else {
            transformedValue = bindingObjectValue;
        }
        
        // In some cases, a different value on screen may not actually be a different value in the model.
        // This happens when part of the model record is split up into multiple parts.
        if ([[_observedObject valueForKeyPath:_observedObjectKeyPath] isEqual:transformedValue]) {
            return;
        }
        
        [_observedObject setValue:transformedValue forKeyPath:_observedObjectKeyPath];
    });
}

- (BOOL)valueAsBool {
    __block BOOL value = NO;
    dispatch_sync(_syncQueue, ^{
        if ([self.bindingObjectValue respondsToSelector:@selector(boolValue)] == YES) {
            value = [self.bindingObjectValue boolValue];
        }
    });
    return value;
}

- (NSInteger)valueAsInteger {
    __block NSInteger value = 0;
    dispatch_sync(_syncQueue, ^{
        if ([self.bindingObjectValue respondsToSelector:@selector(integerValue)] == YES) {
            value = [self.bindingObjectValue integerValue];
        }
    });
    return value;
}

- (long)valueAsLong {
    __block long value = 0;
    dispatch_sync(_syncQueue, ^{
        if ([self.bindingObjectValue respondsToSelector:@selector(longValue)] == YES) {
            value = [self.bindingObjectValue longValue];
        }
    });
    return value;
}

- (float)valueAsFloat {
    __block float value = 0.0;
    dispatch_sync(_syncQueue, ^{
        if ([self.bindingObjectValue respondsToSelector:@selector(floatValue)] == YES) {
            value = [self.bindingObjectValue floatValue];
        }
    });
    return value;
}

- (double)valueAsDouble {
    __block double value = 0.0;
    dispatch_sync(_syncQueue, ^{
        if ([self.bindingObjectValue respondsToSelector:@selector(doubleValue)] == YES) {
            value = [self.bindingObjectValue doubleValue];
        }
    });
    return value;
}

- (NSString *)valueAsString {
    __block NSString *value = nil;
    dispatch_sync(_syncQueue, ^{
        if (self.bindingObjectValue == nil) {
            value = nil;
        } else if ([self.bindingObjectValue isKindOfClass:[NSString class]] == YES) {
            value = self.bindingObjectValue;
        } else if ([self.bindingObjectValue respondsToSelector:@selector(stringValue)] == YES) {
            value = [self.bindingObjectValue stringValue];
        } else {
            value = [self.bindingObjectValue description];
        }
    });
    return value;
}

- (NSDate *)valueAsDate {
    __block NSDate *value = nil;
    dispatch_sync(_syncQueue, ^{
        if (self.bindingObjectValue == nil) {
            value = nil;
        } else if ([self.bindingObjectValue isKindOfClass:[NSDate class]] == YES) {
            value = self.bindingObjectValue;
        } else if ([self.bindingObjectValue isKindOfClass:[NSString class]] == YES) {
            value = [[[NSDateFormatter alloc] init] dateFromString:self.bindingObjectValue];
        } else {
            value = nil;
        }
    });
    return value;
}

- (NSUUID *)valueAsUUID {
    __block NSUUID *value = nil;
    dispatch_sync(_syncQueue, ^{
        if (self.bindingObjectValue == nil) {
            value = nil;
        } else if ([self.bindingObjectValue isKindOfClass:[NSUUID class]] == YES) {
            value = self.bindingObjectValue;
        } else if ([self.bindingObjectValue isKindOfClass:[NSString class]] == YES) {
            value = [[NSUUID alloc] initWithUUIDString:self.bindingObjectValue];
        } else {
            value = nil;
        }
    });
    return value;
}

- (NSData *)valueAsData {
    __block NSData *value = nil;
    dispatch_sync(_syncQueue, ^{
        if (self.bindingObjectValue == nil) {
            value = nil;
        } else if ([self.bindingObjectValue isKindOfClass:[NSData class]] == YES) {
            value = self.bindingObjectValue;
        } else {
            value = nil;
        }
    });
    return value;
}

- (id)valueAsObject {
    return [self.bindingObjectValue isEqual:[NSNull null]] ? nil : self.bindingObjectValue;
}


#pragma mark - Object Lifecycle
- (instancetype)init {
    return [self initWithCoder:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init]) != nil) {
        
        uint propertyCount;
        objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
            if ([propertyName isEqualToString:@"syncQueue"] ||
                [propertyName isEqualToString:@"valueTransformer"] ||
                [propertyName isEqualToString:@"syncQueueIdentifier"] ||
                [propertyName isEqualToString:@"isBound"]) { continue; }
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
        if (propertyCount > 0) {
            free(properties);
        }
        
        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        
        if (_valueTransformerName != nil) {
            _valueTransformer = [NSValueTransformer valueTransformerForName:_valueTransformerName];
        }
        
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    uint propertyCount;
    objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
        if ([propertyName isEqualToString:@"syncQueue"] ||
            [propertyName isEqualToString:@"valueTransformer"] ||
            [propertyName isEqualToString:@"syncQueueIdentifier"] ||
            [propertyName isEqualToString:@"isBound"]) { continue; }
        [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    if (propertyCount > 0) {
        free(properties);
    }
}

#pragma mark - Binding Management
- (void)bind {
    dispatch_barrier_async(_syncQueue, ^{
        
        // The behavior is dependent upon the type.
        
        if (_monitorsObservedObject == YES) {
            
            // Observe the model object.
            [_observedObject addObserver:self
                                  forKeyPath:_observedObjectKeyPath
                                     options:NSKeyValueObservingOptionNew
                                     context:(__bridge void * _Nullable)(_bindingName)];
            
        } 
        
        _isBound = YES;
    });
}

- (void)unbind {
    dispatch_barrier_async(_syncQueue, ^{

        // The behavior is dependent upon the type.
        
        if (_monitorsObservedObject == YES) {
            
            // Observe the controller.
            [_observedObject removeObserver:self
                                     forKeyPath:_observedObjectKeyPath
                                        context:(__bridge void * _Nullable)(_bindingName)];
            
        }
        
        _isBound = NO;
    });
}

#pragma mark - Key Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (context == NULL || context == nil) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else if ([(__bridge NSString * _Nonnull)(context) isKindOfClass: [NSString class]] == NO || [(__bridge NSString * _Nonnull)(context) isEqualToString:_bindingName] == NO) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }

    if (change[NSKeyValueChangeNotificationIsPriorKey] != nil) {
        // TODO: Delegate calls?
    } else {
        if ([change[NSKeyValueChangeOldKey] isEqual:change[NSKeyValueChangeNewKey]] == YES) { return; }
        [self.binder updateValueOfObserverObject];
    }
}

@end
