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
@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;


@end

@implementation RNDBinding

#pragma mark - Properties
@synthesize observedObject = _observedObject;
@synthesize observedObjectKeyPath = _observedObjectKeyPath;
@synthesize observedObjectBindingIdentifier = _observedObjectBindingIdentifier;
@synthesize monitorsObservedObject = _monitorsObservedObject;

@synthesize controllerKey = _controllerKey;
@synthesize binder = _binder;
@synthesize bindingName = _bindingName;

@synthesize isBound = _isBound;

@synthesize nullPlaceholder = _nullPlaceholder;
@synthesize multipleSelectionPlaceholder = _multipleSelectionPlaceholder;
@synthesize notApplicablePlaceholder = _notApplicablePlaceholder;

@synthesize argumentName = _argumentName;
@synthesize valueTransformerName = _valueTransformerName;
@synthesize valueTransformer = _valueTransformer;

@synthesize syncQueueIdentifier = _syncQueueIdentifier;
@synthesize syncQueue = _syncQueue;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize serializerQueue = _serializerQueue;

@synthesize bindingArguments = _bindingArguments;
@synthesize evaluatedObject = _evaluatedObject;

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
    
    return objectValue;
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

- (id)evaluatedObject {
    dispatch_sync(_syncQueue, ^{
    if (_observedObjectKeyPath != nil) {
        _evaluatedObject = [self.observedObject valueForKeyPath:self.observedObjectKeyPath];
    } else {
        _evaluatedObject = self.observedObject;
    }
    });
    return _evaluatedObject;
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
                [propertyName isEqualToString:@"serializerQueueIdentifier"] ||
                [propertyName isEqualToString:@"serializerQueue"] ||
                [propertyName isEqualToString:@"isBound"] ||
                [propertyName isEqualToString:@"observedObject"]) { continue; }
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
        if (propertyCount > 0) {
            free(properties);
        }
        
        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        
        _serializerQueueIdentifier = [[NSUUID alloc] init];
        _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);

        
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
            [propertyName isEqualToString:@"isBound"] ||
            [propertyName isEqualToString:@"observedObject"]) { continue; }
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
        NSUInteger index = [self.binder.observer.bindingDestinations indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([((id<RNDBindableObject>)obj).bindingIdentifier isEqualToString:_observedObjectBindingIdentifier]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (index == NSNotFound) {
            _isBound = NO;
            return;
        }
        
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

- (BOOL)bind:(NSError * _Nonnull __autoreleasing *)error {
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        NSUInteger index = [self.binder.observer.bindingDestinations indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([((id<RNDBindableObject>)obj).bindingIdentifier isEqualToString:_observedObjectBindingIdentifier]) {
                _observedObject = obj;
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if (index == NSNotFound) {
            _isBound = NO;
            result = _isBound;
            return;
        }

        if (_monitorsObservedObject == YES) {
            
            // Observe the model object.
            [_observedObject addObserver:self
                              forKeyPath:_observedObjectKeyPath
                                 options:NSKeyValueObservingOptionNew
                                 context:(__bridge void * _Nullable)(_bindingName)];
            
        }
        
        _isBound = YES;
        result = _isBound;
    });
    return result;
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

- (BOOL)unbind:(NSError * _Nonnull __autoreleasing *)error {
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        
        // The behavior is dependent upon the type.
        
        if (_monitorsObservedObject == YES) {
            
            // Observe the controller.
            [_observedObject removeObserver:self
                                 forKeyPath:_observedObjectKeyPath
                                    context:(__bridge void * _Nullable)(_bindingName)];
            
        }
        
        _isBound = NO;
        result = _isBound;
    });
    return result;
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
