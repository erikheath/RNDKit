//
//  RNDBindingProcessor.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinder.h"
#import "RNDBindingProcessor.h"
#import "RNDPredicateProcessor.h"
#import "RNDPatternedStringProcessor.h"
#import <objc/runtime.h>

// TODO: Mutual Exclusion ID? Add the ids of the executed bindings
// TODO: If the value is a placeholder, you can't write to it.

@interface RNDBindingProcessor ()

@property (strong, nullable, readonly) NSUUID *syncQueueIdentifier;

@end

@implementation RNDBindingProcessor

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

- (void)setNullPlaceholder:(RNDBindingProcessor *)nullPlaceholder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _nullPlaceholder = nullPlaceholder;
    });
}

- (RNDBindingProcessor *)nullPlaceholder {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _nullPlaceholder;
    });
    return localObject;
}


@synthesize multipleSelectionPlaceholder = _multipleSelectionPlaceholder;

- (void)setMultipleSelectionPlaceholder:(RNDBindingProcessor *)multipleSelectionPlaceholder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _multipleSelectionPlaceholder = multipleSelectionPlaceholder;
    });
}

- (RNDBindingProcessor *)multipleSelectionPlaceholder {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _multipleSelectionPlaceholder;
    });
    return localObject;
}


@synthesize notApplicablePlaceholder = _notApplicablePlaceholder;

- (void)setNotApplicablePlaceholder:(RNDBindingProcessor *)notApplicablePlaceholder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _notApplicablePlaceholder = notApplicablePlaceholder;
    });
}

- (RNDBindingProcessor *)notApplicablePlaceholder {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _notApplicablePlaceholder;
    });
    return localObject;
}


@synthesize nilPlaceholder = _nilPlaceholder;

- (void)setNilPlaceholder:(RNDBindingProcessor *)nilPlaceholder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _nilPlaceholder = nilPlaceholder;
    });
}

- (RNDBindingProcessor *)nilPlaceholder {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _nilPlaceholder;
    });
    return localObject;
}


@synthesize noSelectionPlaceholder = _noSelectionPlaceholder;

- (void)setNoSelectionPlaceholder:(RNDBindingProcessor *)noSelectionPlaceholder {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _noSelectionPlaceholder = noSelectionPlaceholder;
    });
}

- (RNDBindingProcessor *)noSelectionPlaceholder {
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


@synthesize processorArguments = _processorArguments;

- (void)setProcessorArguments:(NSMutableArray<RNDBindingProcessor *> *)processorArguments {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _processorArguments = processorArguments;
    });
}

- (NSMutableArray<RNDBindingProcessor *> *)processorArguments {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _processorArguments;
    });
    return localObject;
}


@synthesize observedObjectEvaluator = _observedObjectEvaluator;

- (void)setObservedObjectEvaluator:(RNDPredicateProcessor *)observedObjectEvaluator {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        if (observedObjectEvaluator == nil) {
            _observedObjectEvaluator = [[RNDPredicateProcessor alloc] init];
        } else {
            _observedObjectEvaluator = observedObjectEvaluator;
        }
        _observedObjectEvaluator.processorOutputType = RNDCalculatedValueOutputType;
    });
}

- (RNDPredicateProcessor *)observedObjectEvaluator {
    RNDPredicateProcessor __block *localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _observedObjectEvaluator;
    });
    return localObject;
}


@synthesize processorOutputType = _processorOutputType;

- (void)setProcessorOutputType:(RNDProcessorValueType)processorOutputType {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _processorOutputType = processorOutputType;
    });
}

- (RNDProcessorValueType)processorOutputType {
    RNDProcessorValueType __block localValue;
    dispatch_sync(self.syncQueue, ^{
        localValue = _processorOutputType;
    });
    return localValue;
}


@synthesize runtimeArguments = _runtimeArguments;

- (void)setRuntimeArguments:(NSDictionary *)runtimeArguments {
    dispatch_barrier_sync(_syncQueue, ^{
        _runtimeArguments = runtimeArguments != nil ? runtimeArguments : @{};
        for (RNDBindingProcessor *binding in self.processorNodes) {
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
        
        id rawObjectValue;
        
        NSMutableArray *keyPathArray = [NSMutableArray array];
        if (_controllerKey != nil) { [keyPathArray addObject:_controllerKey]; }
        if (_observedObjectKeyPath != nil) { [keyPathArray addObject:_observedObjectKeyPath]; }
        NSString *keyPath = [keyPathArray componentsJoinedByString:@"."];

        if (_observedObjectEvaluator != nil && ((NSNumber *)_observedObjectEvaluator.bindingObjectValue).boolValue == NO ) {
            rawObjectValue = nil;
        } else {
            rawObjectValue = [_observedObject valueForKeyPath:keyPath];
        }
        
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
        
        if ([rawObjectValue isEqual: RNDBindingNullValueMarker] == YES || rawObjectValue == [NSNull null]) {
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

- (id)observedObjectEvaluationValue {
    id __block localObject = nil;
    dispatch_sync(_syncQueue, ^{
        NSMutableArray *keyPathArray = [NSMutableArray array];
        if (_controllerKey != nil) { [keyPathArray addObject:_controllerKey]; }
        if (_observedObjectKeyPath != nil) { [keyPathArray addObject:_observedObjectKeyPath]; }
        NSString *keyPath = [keyPathArray componentsJoinedByString:@"."];
        if ([keyPath isEqualToString:@""] == NO) {
            localObject = [_observedObject valueForKeyPath:keyPath];
        } else {
            localObject = _observedObject;
        }
    });
    return localObject;
}

- (NSArray<RNDBindingProcessor *> *)processorNodes {
    NSMutableArray * __block bindings = [NSMutableArray array];
    if (_processorArguments != nil) {
        [bindings addObjectsFromArray:_processorArguments];
    }
    if (_userString != nil) {
        [bindings addObject:_userString];
    }
    if (_observedObjectEvaluator != nil) {
        [bindings addObject:_observedObjectEvaluator];
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
    if ((self = [super init]) != nil) {
        _runtimeArguments = @{};
        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        _processorArguments = [NSMutableArray array];
    }
    return self;
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
        
        _runtimeArguments = @{};
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
    BOOL result = YES;
    NSError *internalError = nil;
    
    dispatch_assert_queue_barrier_debug(_syncQueue);
    
    if (_isBound == YES) {
        result = NO;
        if (error != NULL) {
            NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
            internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                code:RNDObjectIsBoundError
                                            userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundErrorKey, nil, errorBundle, @"The processor is already bound.", @"The processor is already bound."),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundRecoverySuggestionErrorKey, nil, errorBundle, @"The processor is already bound. To rebind the processor, call unbind on the processor first.", @"Attempted to rebind the processor.")
                                                       }];
            *error = internalError;
        }
        return result;
    }
    
    if (_observedObject == nil && _observedObjectBindingIdentifier != nil) {
        NSUInteger index = [_binder.observer.bindingDestinations indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([((id<RNDBindableObject>)obj).bindingIdentifier isEqualToString:_observedObjectBindingIdentifier]) {
                _observedObject = obj;
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if (index == NSNotFound) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                code:RNDObservedObjectNotFound
                                    userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDObservedObjectNotFoundErrorKey, nil, errorBundle, @"Unable to locate the observed object.", @"Unable to locate the observed object."),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDBindingIdentifierRecoverySuggestionErrorKey, nil, errorBundle, @"Confirm that the binding identifier exists in the Interface Builder file and points to the desired observed object. Alternatively, reconnect the binding processor to the correct destination in the RNDWorkbench application.", @"The binder identifier could not be located in the binding destinations provided by the binder.")
                                                       }];
                *error = internalError;
            }
            return result;
        }
    }
    
    if (_monitorsObservedObject == YES) {
        if (_observedObject == nil) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDObservedObjectIsNil
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDObservedObjectIsNilErrorKey, nil, errorBundle, @"The observed object is nil.", @"The observed object is nil."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectRecoverySuggestionErrorKey, nil, errorBundle, @"If loading from an archive, confirm that the binding identifier exists in the Interface Builder file and points to the desired observed object. Alternatively, reconnect the binding processor to the correct destination in the RNDWorkbench application and regenerate the archive.\n\nIf not loading from an archive, confirm that the observed object is set prior to attempting to bind the processor.", @"The observed object is nil and can not be KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;
        } else if ([_observedObject isKindOfClass:[RNDBindingProcessor class]] == YES) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDAttemptToObserveProcessorError
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectErrorKey, nil, errorBundle, @"The observed object is a processor.", @"The observed object is a processor."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectRecoverySuggestionErrorKey, nil, errorBundle, @"The processor has been set to monitor another processor. Processors can not be monitored. Change the monitors observer setting of this processor to false to correct this error./n/n If you are using the RNDWorkbench, uncheck the monitors observer checkbox for this processor.", @"The observed object is a processor and can not be KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;

        }
        
        NSMutableArray *keyPathArray = [NSMutableArray array];
        if (_controllerKey != nil) { [keyPathArray addObject:_controllerKey]; }
        if (_observedObjectKeyPath != nil) { [keyPathArray addObject:_observedObjectKeyPath]; }
        NSString *keyPath = [keyPathArray componentsJoinedByString:@"."];

        // Observe the model object.
        [_observedObject addObserver:self
                          forKeyPath:keyPath
                             options:NSKeyValueObservingOptionNew
                             context:(__bridge void * _Nullable)(_bindingName)];
    }
    
    // The observed object must recieve a bind message.
    if ([_observedObject isKindOfClass:[RNDBindingProcessor class]] == YES) {
        ((RNDBindingProcessor *)_observedObject).binder = _binder;
        result = [(RNDBindingProcessor *)_observedObject bind:&internalError];
        if (result == NO) {
            [self unbind:NULL];
            if (error != NULL) { *error = internalError; }
            return result;
        }
    }
    
    for (RNDBindingProcessor *binding in self.processorNodes) {
        binding.binder = _binder;
        if ((result = [binding bind:&internalError]) == YES) { continue; }
        [self unbind:NULL];
        if (error != NULL) { *error = internalError; }
        break;
    }
    
    _isBound = result;
    return result;
}

- (void)bind {
    dispatch_barrier_sync(_syncQueue, ^{
        [self bindObjects:NULL];
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
    BOOL result = YES;
    id underlyingError;
    NSError * internalError;
    
    dispatch_assert_queue_barrier_debug(_syncQueue);
    
    @try {
        if (_isBound == YES && _monitorsObservedObject == YES) {
            NSMutableArray *keyPathArray = [NSMutableArray array];
            if (_controllerKey != nil) { [keyPathArray addObject:_controllerKey]; }
            if (_observedObjectKeyPath != nil) { [keyPathArray addObject:_observedObjectKeyPath]; }
            NSString *keyPath = [keyPathArray componentsJoinedByString:@"."];
            
            // Remove the observer.
            [_observedObject removeObserver:self
                                 forKeyPath:keyPath
                                    context:(__bridge void * _Nullable)(_bindingName)];
        }
    }
    
    @catch (id exception) {
        result = NO;
        if (error != NULL) {
            if ([exception isKindOfClass:[NSException class]] == YES) {
                NSException * exceptionObj = (NSException *)exception;
                NSMutableDictionary *exceptionDictionary = [NSMutableDictionary dictionaryWithDictionary:exceptionObj.userInfo != nil ? exceptionObj.userInfo : @{}];
                [exceptionDictionary addEntriesFromDictionary:@{NSLocalizedDescriptionKey: exceptionObj.name, NSLocalizedFailureReasonErrorKey: exceptionObj.reason != nil ? exceptionObj.reason : [NSNull null]}];
                underlyingError = [NSError errorWithDomain:RNDKitErrorDomain
                                                            code:RNDExceptionAsError
                                                        userInfo:[NSDictionary dictionaryWithDictionary:exceptionDictionary]];
            } else {
                underlyingError = exception;
            }
        }
    }
    
    NSMutableArray *underlyingErrorsArray = [NSMutableArray array];
    for (RNDBindingProcessor *binding in self.processorNodes) {
        NSError *passedInError;
        BOOL unbindingResult = [binding unbind:&passedInError];
        if (unbindingResult == NO) {
            result = NO;
            [underlyingErrorsArray addObject:passedInError];
        }
    }
    
    // The observed object must be unbound.
    if ([_observedObject isKindOfClass:[RNDBindingProcessor class]] == YES) {
        NSError *observedUnbindingError;
        BOOL unbindingResult = [(RNDBindingProcessor *)_observedObject unbind:&observedUnbindingError];
        if (unbindingResult == NO) {
            result = NO;
            [underlyingErrorsArray addObject:observedUnbindingError];
        }
    }

    
    if (error != NULL && (underlyingErrorsArray.count > 0 || underlyingError != nil)) {
        NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
        internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                            code:RNDProcessorIsNotRegisteredAsObserver
                                        userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDUnbindingErrorKey, nil, errorBundle, @"Unbinding Error", @"Unbinding Error"),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDUnbindingUnregistrationErrorKey, nil, errorBundle, @"An error occurred during unbinding.", @"An error occurred during unbinding."),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDUnbindingExceptionRecoverySuggestionErrorKey, nil, errorBundle, @"An exception was thrown during unbinding. The most likely cause is that the processor was not registered as an observer of the observed object. See the underlying error for more information and to trace the cause of the exception.", @"The processor was not registered as an observer."),
                                                   NSUnderlyingErrorKey:underlyingError,
                                                   RNDUnderlyingErrorsArrayKey: underlyingErrorsArray
                                                   }];
        *error = internalError;
    }

    _isBound = NO;
    return result;
}

- (void)unbind {
    dispatch_barrier_sync(_syncQueue, ^{
        [self unbindObjects:NULL];
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
