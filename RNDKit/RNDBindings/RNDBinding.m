//
//  RNDBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinding.h"
#import "RNDBinder.h"
#import "RNDPredicateBinding.h"
#import "RNDPatternedBinding.h"
#import <objc/runtime.h>


@interface RNDBinding ()

@property (strong, nullable, readonly) NSUUID *syncQueueIdentifier;

@end

@implementation RNDBinding

#pragma mark - Properties
@synthesize observedObject = _observedObject;

- (void)setObservedObject:(NSObject *)observedObject {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _observedObject = observedObject;
    });
}

- (NSString *)observedObject {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _observedObject;
    });
    return localObject;
}


@synthesize observedObjectKeyPath = _observedObjectKeyPath;

- (void)setObservedObjectKeyPath:(NSString *)observedObjectKeyPath {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _observedObjectKeyPath = observedObjectKeyPath;
    });
}

- (NSString *)observedObjectKeyPath {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _observedObjectKeyPath;
    });
    return localObject;
}


@synthesize observedObjectBindingIdentifier = _observedObjectBindingIdentifier;

- (void)setObservedObjectBindingIdentifier:(NSString *)observedObjectBindingIdentifier {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _observedObjectBindingIdentifier = observedObjectBindingIdentifier;
    });
}

- (NSString *)observedObjectBindingIdentifier {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _observedObjectBindingIdentifier;
    });
    return localObject;
}


@synthesize monitorsObservedObject = _monitorsObservedObject;

- (void)setMonitorsObservedObject:(BOOL)monitorsObservedObject {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _monitorsObservedObject = monitorsObservedObject;
    });
}

- (BOOL)monitorsObservedObject {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _monitorsObservedObject;
    });
    return localObject;
}


@synthesize controllerKey = _controllerKey;

- (void)setControllerKey:(NSString *)controllerKey {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _controllerKey = controllerKey;
    });
}

- (NSString *)controllerKey {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _controllerKey;
    });
    return localObject;
}


@synthesize binder = _binder;

- (void)setBinder:(RNDBinder *)binder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _binder = binder;
    });
}

- (RNDBinder *)binder {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _binder;
    });
    return localObject;
}


@synthesize bindingName = _bindingName;

- (void)setBindingName:(NSString *)bindingName {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _bindingName = bindingName;
    });
}

- (NSString *)bindingName {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _bindingName;
    });
    return localObject;
}


@synthesize nullPlaceholder = _nullPlaceholder;

- (void)setNullPlaceholder:(RNDBinding *)nullPlaceholder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _nullPlaceholder = nullPlaceholder;
    });
}

- (RNDBinding *)nullPlaceholder {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _nullPlaceholder;
    });
    return localObject;
}


@synthesize multipleSelectionPlaceholder = _multipleSelectionPlaceholder;

- (void)setMultipleSelectionPlaceholder:(RNDBinding *)multipleSelectionPlaceholder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _multipleSelectionPlaceholder = multipleSelectionPlaceholder;
    });
}

- (RNDBinding *)multipleSelectionPlaceholder {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _multipleSelectionPlaceholder;
    });
    return localObject;
}


@synthesize notApplicablePlaceholder = _notApplicablePlaceholder;

- (void)setNotApplicablePlaceholder:(RNDBinding *)notApplicablePlaceholder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _notApplicablePlaceholder = notApplicablePlaceholder;
    });
}

- (RNDBinding *)notApplicablePlaceholder {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _notApplicablePlaceholder;
    });
    return localObject;
}


@synthesize nilPlaceholder = _nilPlaceholder;

- (void)setNilPlaceholder:(RNDBinding *)nilPlaceholder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _nilPlaceholder = nilPlaceholder;
    });
}

- (RNDBinding *)nilPlaceholder {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _nilPlaceholder;
    });
    return localObject;
}


@synthesize noSelectionPlaceholder = _noSelectionPlaceholder;

- (void)setNoSelectionPlaceholder:(RNDBinding *)noSelectionPlaceholder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _noSelectionPlaceholder = noSelectionPlaceholder;
    });
}

- (RNDBinding *)noSelectionPlaceholder {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _noSelectionPlaceholder;
    });
    return localObject;
}


@synthesize argumentName = _argumentName;

- (void)setArgumentName:(NSString *)argumentName {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _argumentName = argumentName;
    });
}

- (NSString *)argumentName {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _argumentName;
    });
    return localObject;
}


@synthesize valueTransformerName = _valueTransformerName;

- (void)setValueTransformerName:(NSString *)valueTransformerName {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _valueTransformerName = valueTransformerName;
    });
}

- (NSString *)valueTransformerName {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _valueTransformerName;
    });
    return localObject;
}


@synthesize bindingArguments = _bindingArguments;

- (void)setBindingArguments:(NSMutableArray<RNDBinding *> *)bindingArguments {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _bindingArguments = bindingArguments;
    });
}

- (NSMutableArray<RNDBinding *> *)bindingArguments {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _bindingArguments;
    });
    return localObject;
}


@synthesize evaluator = _evaluator;

- (void)setEvaluator:(RNDPredicateBinding *)evaluator {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _evaluator = evaluator;
    });
}

- (RNDPredicateBinding *)evaluator {
    RNDPredicateBinding __block *localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _evaluator;
    });
    return localObject;
}


@synthesize evaluates = _evaluates;

- (void)setEvaluates:(BOOL)evaluates {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _evaluates = evaluates;
    });
}

- (BOOL)evaluates {
    BOOL __block localBool;
    dispatch_sync(self.syncQueue, ^{
        localBool = _evaluates;
    });
    return localBool;
}


@synthesize runtimeArguments = _runtimeArguments;

- (void)setRuntimeArguments:(NSDictionary *)runtimeArguments {
    dispatch_barrier_sync(_syncQueue, ^{
        _runtimeArguments = runtimeArguments;
        for (RNDBinding *binding in self.allBindings) {
            binding.runtimeArguments = _runtimeArguments;
        }
    });
}

- (NSDictionary *)runtimeArguments {
    id __block localObject = nil;
    dispatch_sync(_syncQueue, ^{
        localObject = _runtimeArguments;
    });
    return localObject;
}

#pragma mark - Transient (Calculated) Properties
@synthesize valueTransformer = _valueTransformer;
@synthesize syncQueueIdentifier = _syncQueueIdentifier;
@synthesize syncQueue = _syncQueue;
@synthesize isBound = _isBound;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(_syncQueue, ^{
        
        if (_isBound == NO) {
            objectValue = nil;
            return;
        }
        
        if (((NSNumber *)_evaluator.bindingObjectValue).boolValue == NO ) {
            objectValue = nil;
            return;
        }
        
        id rawObjectValue = [_observedObject valueForKeyPath:_observedObjectKeyPath];
        
        
        if ([rawObjectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
            objectValue = _multipleSelectionPlaceholder != nil ? _multipleSelectionPlaceholder.bindingObjectValue : rawObjectValue;
            return;
        }
        
        if ([rawObjectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
            objectValue = _noSelectionPlaceholder != nil ? _noSelectionPlaceholder.bindingObjectValue : rawObjectValue;
            return;
        }
        
        if ([rawObjectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
            objectValue = _notApplicablePlaceholder != nil ? _notApplicablePlaceholder.bindingObjectValue : rawObjectValue;
            return;
        }
        
        if ([rawObjectValue isEqual: RNDBindingNullValueMarker] == YES) {
            objectValue = _nullPlaceholder != nil ? _nullPlaceholder.bindingObjectValue : rawObjectValue;
            return;
        }
        
        if (rawObjectValue == nil) {
            objectValue = _nilPlaceholder != nil ? _nilPlaceholder.bindingObjectValue : rawObjectValue;
            return;
        }
        
        
        objectValue = _valueTransformer != nil ? [_valueTransformer transformedValue:rawObjectValue] : rawObjectValue;
        
    });
    
    return objectValue;
}

- (void)setBindingObjectValue:(id)bindingObjectValue {
    dispatch_barrier_async(_syncQueue, ^{
        // In some cases, a different value on screen may not actually be a different value in the model.
        // This happens when part of the model record is split up into multiple parts.
        
        // Set the context of the binding so that the runtime arguments can be used.
        NSMutableDictionary *contextDictionary = [NSMutableDictionary dictionaryWithDictionary:@{RNDBinderObjectValue: bindingObjectValue}];
        dispatch_set_context(self.syncQueue, (__bridge void * _Nullable)(contextDictionary));
        
        // There may be no actual change, in which case nothing needs to happen.
        id objectValue = self.bindingObjectValue;
        if ([objectValue isEqual:[_observedObject valueForKeyPath:_observedObjectKeyPath]]) {
            return;
        }
        
        [_observedObject setValue:self.bindingObjectValue forKeyPath:_observedObjectKeyPath];
    });
}

- (id)evaluatedObject {
    id __block localObject = nil;
    dispatch_sync(_syncQueue, ^{
        if (_observedObjectKeyPath != nil) {
            localObject = [_observedObject valueForKeyPath:_observedObjectKeyPath];
        } else {
            localObject = _observedObject;
        }
    });
    return localObject;
}

- (NSArray<RNDBinding *> *)allBindings {
    NSMutableArray * __block bindings = [NSMutableArray array];
    if (_bindingArguments != nil) {
        [bindings addObjectsFromArray:_bindingArguments];
    }
    if (_userString != nil) {
        [bindings addObject:_userString];
    }
    if (_evaluator != nil) {
        [bindings addObject:_evaluator];
    }
    if (_nilPlaceholder != nil) {
        [bindings addObject:_nilPlaceholder];
    }
    if (_nullPlaceholder != nil) {
        [bindings addObject:_nullPlaceholder];
    }
    if (_multipleSelectionPlaceholder != nil) {
        [bindings addObject:_multipleSelectionPlaceholder];
    }
    if (_noSelectionPlaceholder != nil) {
        [bindings addObject:_noSelectionPlaceholder];
    }
    if (_notApplicablePlaceholder != nil) {
        [bindings addObject:_notApplicablePlaceholder];
    }
    return bindings;
}

#pragma mark - Object Lifecycle
- (instancetype)init {
    return [super init];
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
                [propertyName isEqualToString:@"isBound"] ||
                [propertyName isEqualToString:@"observedObject"]) { continue; }
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
            [propertyName isEqualToString:@"isBound"] ||
            [propertyName isEqualToString:@"observedObject"]) { continue; }
        [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    if (propertyCount > 0) {
        free(properties);
    }
}

#pragma mark - Binding Management

- (BOOL)bindObjects:(NSError * _Nonnull __autoreleasing *)error {
    
    dispatch_assert_queue_barrier(_syncQueue);
    
    NSUInteger index = [_binder.observer.bindingDestinations indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([((id<RNDBindableObject>)obj).bindingIdentifier isEqualToString:_observedObjectBindingIdentifier]) {
            _observedObject = obj;
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (index == NSNotFound) {
        _isBound = NO;
        return _isBound;
    }
    
    if (_monitorsObservedObject == YES) {
        
        // Observe the model object.
        [_observedObject addObserver:self
                          forKeyPath:_observedObjectKeyPath
                             options:NSKeyValueObservingOptionNew
                             context:(__bridge void * _Nullable)(_bindingName)];
        
    }
    
    for (RNDBinding *binding in self.allBindings) {
        binding.binder = _binder;
        if ([binding bindObjects:error] == YES) { continue; }
        [self unbindObjects:error];
        _isBound = NO;
        return _isBound;
    }

    _isBound = YES;
    return _isBound;
}

- (void)bind {
    dispatch_barrier_async(_syncQueue, ^{
        [self bindObjects:nil];
    });
}

- (BOOL)bind:(NSError * _Nullable __autoreleasing *)error {
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        result = [self bindObjects:error];
    });
    return result;
}

- (BOOL)unbindObjects:(NSError * _Nullable __autoreleasing *)error {
    
    dispatch_assert_queue_barrier(_syncQueue);

    if (_monitorsObservedObject == YES) {
        
        // Remove the observer.
        [_observedObject removeObserver:self
                             forKeyPath:_observedObjectKeyPath
                                context:(__bridge void * _Nullable)(_bindingName)];
        
    }
    
    for (RNDBinding *binding in self.allBindings) {
        [binding unbindObjects:error];
    }
    
    _isBound = NO;
    return _isBound;
}

- (void)unbind {
    dispatch_barrier_async(_syncQueue, ^{
        [self unbindObjects:nil];
    });
}

- (BOOL)unbind:(NSError * _Nullable __autoreleasing *)error {
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        result = [self unbindObjects:error];
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
