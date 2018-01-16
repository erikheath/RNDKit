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

@property (strong, nullable, readonly) NSUUID *coordinatorQueueIdentifier;

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

- (NSMutableArray<RNDBindingProcessor *> *)processorArguments {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _processorArguments;
    });
    return localObject;
}

@synthesize boundProcessorArguments = _boundProcessorArguments;

- (NSArray<RNDBindingProcessor *> *)boundProcessorArguments {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _boundProcessorArguments;
    });
    return localObject;
}

@synthesize processorCondition = _processorCondition;

- (void)setProcessorCondition:(RNDPredicateProcessor *)observedObjectEvaluator {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        if (observedObjectEvaluator == nil) {
            _processorCondition = [[RNDPredicateProcessor alloc] init];
        } else {
            _processorCondition = observedObjectEvaluator;
        }
        _processorCondition.processorOutputType = RNDCalculatedValueOutputType;
    });
}

- (RNDPredicateProcessor *)processorCondition {
    RNDPredicateProcessor __block *localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _processorCondition;
    });
    return localObject;
}


@synthesize processorValueMode = _processorValueMode;

- (void)setProcessorValueMode:(RNDValueMode)processorValueMode {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _processorValueMode = processorValueMode;
    });
}

- (RNDValueMode)processorValueMode {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _processorValueMode;
    });
    return localObject;
}


@synthesize processorOutputType = _processorOutputType;

- (void)setProcessorOutputType:(RNDProcessorOutputType)processorOutputType {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _processorOutputType = processorOutputType;
    });
}

- (RNDProcessorOutputType)processorOutputType {
    RNDProcessorOutputType __block localValue;
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

@synthesize unwrapSingleValue = _unwrapSingleValue;

- (void)setUnwrapSingleValue:(BOOL)unwrapSingleValue {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _unwrapSingleValue = unwrapSingleValue;
    });
}

- (BOOL)unwrapSingleValue {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _unwrapSingleValue;
    });
    return localObject;
}

#pragma mark - Transient (Calculated) Properties
@synthesize valueTransformer = _valueTransformer;
@synthesize coordinatorQueueIdentifier = _coordinatorQueueIdentifier;
@synthesize syncQueue = _syncQueue;
@synthesize syncCoordinator = _syncCoordinator;
@synthesize bound = _isBound;

- (id _Nullable)bindingValue {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    
    id __block objectValue = nil;

    // Check the bound status
    if (_isBound == NO) {
        objectValue = nil;
        dispatch_semaphore_signal(_syncCoordinator);
        return objectValue;
    }
    
    dispatch_sync(_syncQueue, ^{
        objectValue = [self coordinatedBindingValue];
    });
    
    dispatch_semaphore_signal(_syncCoordinator);
    
    return objectValue;
}

- (id _Nullable)coordinatedBindingValue {
    //Check the queue
    dispatch_assert_queue_debug(_syncQueue);
    
    id objectValue = nil;
    
    // Generate the raw value
    objectValue = [self rawBindingValue:nil];
    
    // Apply calculations to the value
    objectValue = [self calculatedBindingValue: objectValue];
    
    // Filter the value
    objectValue = [self filteredBindingValue:objectValue];
    
    // Transform the value
    objectValue = [self transformedBindingValue:objectValue];
    
    // Generate the value label
    NSString *entryString = self.bindingValueLabel.bindingValue;
    entryString = entryString != nil ? entryString : [NSString stringWithFormat:@"%lu", 1ul];
    
    // Wrap the value in the default form
    if (objectValue != nil) {
        objectValue = @[@{entryString:objectValue}];
    } else {
        objectValue = @[@{}];
    }
    
    // Apply the correct wrapping to the value.
    objectValue = [self wrappedBindingValue:objectValue];

    return objectValue;
}

- (id _Nullable)rawBindingValue:(id _Nullable)bindingValue {
    id __block rawObjectValue;
    
    NSString * keyPath = self.resolvedObservedObjectKeyPath;
    
    if (_processorCondition != nil && ((NSNumber *)_processorCondition.bindingValue).boolValue == NO ) {
        rawObjectValue = nil;
    } else {
        if (self.readOnMainQueue == YES) {
            dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
                rawObjectValue = [_observedObject valueForKeyPath:keyPath];
            });
            dispatch_async(dispatch_get_main_queue(), block);
            dispatch_block_wait(block, DISPATCH_TIME_FOREVER);

        } else {
            rawObjectValue = [_observedObject valueForKeyPath:keyPath];
        }
    }

    return rawObjectValue;
}

- (id _Nullable)calculatedBindingValue:(id _Nullable)bindingValue {
    return bindingValue;
}

- (id _Nullable)filteredBindingValue:(id _Nullable)bindingValue {
    id objectValue = nil;
    if ([bindingValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
        objectValue = _multipleSelectionPlaceholder != nil ? _multipleSelectionPlaceholder.bindingValue : bindingValue;
        return objectValue;
    }
    
    if ([bindingValue isEqual: RNDBindingNoSelectionMarker] == YES) {
        objectValue = _noSelectionPlaceholder != nil ? _noSelectionPlaceholder.bindingValue : bindingValue;
        return objectValue;
    }
    
    if ([bindingValue isEqual: RNDBindingNotApplicableMarker] == YES) {
        objectValue = _notApplicablePlaceholder != nil ? _notApplicablePlaceholder.bindingValue : bindingValue;
        return objectValue;
    }
    
    if ([bindingValue isEqual: RNDBindingNullValueMarker] == YES || bindingValue == [NSNull null]) {
        objectValue = _nullPlaceholder != nil ? _nullPlaceholder.bindingValue : bindingValue;
        return objectValue;
    }
    
    if (bindingValue == nil) {
        objectValue = _nilPlaceholder != nil ? _nilPlaceholder.bindingValue : bindingValue;
        return objectValue;
    }

    objectValue = bindingValue;
    
    return objectValue;
}

- (id _Nullable)transformedBindingValue:(id _Nullable)bindingValue {
    return _valueTransformer != nil ? [_valueTransformer transformedValue:bindingValue] : bindingValue;
}

- (id _Nullable)wrappedBindingValue:(id)bindingValue {
    id objectValue = nil;
    NSArray *valuesArray = (NSArray *)bindingValue;
    
    switch (_processorValueMode) {
        case RNDValueOnlyMode:
        {
            NSMutableArray *valueOnlyArray = [NSMutableArray arrayWithCapacity:valuesArray.count];
            for (NSDictionary *dictionary in valuesArray) {
                [valueOnlyArray addObjectsFromArray:[dictionary allValues]];
            }
            objectValue = _unwrapSingleValue == YES ? (valueOnlyArray.count < 2 ? valueOnlyArray.firstObject : valueOnlyArray) : valueOnlyArray;
            break;
        }
        case RNDKeyedValueMode:
        {
            NSMutableDictionary *keyedValueDictionary = [NSMutableDictionary dictionaryWithCapacity:valuesArray.count];
            for (NSDictionary *dictionary in valuesArray) {
                [keyedValueDictionary addEntriesFromDictionary:dictionary];
            }
            objectValue = keyedValueDictionary;
            break;
        }
        case RNDOrderedKeyedValueMode:
        {
            objectValue = valuesArray;
            break;
        }
        default:
        {
            objectValue = valuesArray;
            break;
        }
    }
    
    return objectValue;
}

- (id)observedObjectBindingValue {
    id __block localObject = nil;
    dispatch_sync(_syncQueue, ^{
        NSString *keyPath = self.resolvedObservedObjectKeyPath;
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
    if (_bindingValueLabel != nil) {
        [bindings addObject:_bindingValueLabel];
    }
    if (_processorCondition != nil) {
        [bindings addObject:_processorCondition];
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

- (NSString * _Nullable)resolvedObservedObjectKeyPath {
    NSMutableArray *keyPathArray = [NSMutableArray array];
    if (_controllerKey != nil) { [keyPathArray addObject:_controllerKey]; }
    if (_observedObjectKeyPath != nil) { [keyPathArray addObject:_observedObjectKeyPath]; }
    NSString *keyPath = [keyPathArray componentsJoinedByString:@"."];
    return keyPath;
}


#pragma mark - Object Lifecycle
- (instancetype)init {
    if ((self = [super init]) != nil) {
        _runtimeArguments = @{};
        _coordinatorQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_coordinatorQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        _syncCoordinator = dispatch_semaphore_create(1);
        _processorArguments = [NSMutableArray array];
        _unwrapSingleValue = YES;
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
                [propertyName isEqualToString:@"coordinatorQueueIdentifier"] ||
                [propertyName isEqualToString:@"isBound"] ||
                [propertyName isEqualToString:@"observedObject"] ||
                [propertyName isEqualToString:@"readWriteCoordinator"]) { continue; }
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
        if (propertyCount > 0) {
            free(properties);
        }
        
        _coordinatorQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_coordinatorQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        _syncCoordinator = dispatch_semaphore_create(1);

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
            [propertyName isEqualToString:@"coordinatorQueueIdentifier"] ||
            [propertyName isEqualToString:@"isBound"] ||
            [propertyName isEqualToString:@"observedObject"] ||
            [propertyName isEqualToString:@"readWriteCoordinator"]) { continue; }
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
    
    dispatch_assert_queue_debug(_syncQueue);
    
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
        NSUInteger index = [_binder.bindingObject.bindingDestinations indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectRecoverySuggestionErrorKey, nil, errorBundle, @"The processor has been set to monitor another processor. Processors can not be monitored. Change the monitors observer setting of this processor to false to correct this error./n/nIf you are using the RNDWorkbench, uncheck the monitors observer checkbox for this processor.", @"The observed object is a processor and can not be KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;

        } else if (_observedObjectKeyPath == nil) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDKeyValuePathError
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDKeyPathIsNilErrorKey, nil, errorBundle, @"The observed object keypath is nil.", @"The observed object keypath is nil."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectRecoverySuggestionErrorKey, nil, errorBundle, @"A keypath corresponding to an observable relationship of an object must be specified to enable monitoring./n/nIf you are using the RNDWorkbench, either uncheck the monitors observed checkbox for this processor or specify an observable property keypath to monitor.", @"The keypath of the observed object is nil and will prevent the observed object from being KVO'd.")
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
    _boundProcessorArguments = [NSArray arrayWithArray:self.processorNodes];
    for (RNDBindingProcessor *binding in _boundProcessorArguments) {
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
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    dispatch_sync(_syncQueue, ^{
        [self bindObjects:NULL];
    });
    dispatch_semaphore_signal(_syncCoordinator);
}

- (BOOL)bind:(NSError * _Nullable __autoreleasing *)error {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        result = [self bindObjects:error];
    });
    dispatch_semaphore_signal(_syncCoordinator);
    return result;
}

- (BOOL)unbindObjects:(NSError * _Nullable __autoreleasing *)error {
    BOOL result = YES;
    id underlyingError;
    NSMutableArray *underlyingErrorsArray = [NSMutableArray array];
    NSError * internalError;
    
    dispatch_assert_queue_debug(_syncQueue);
    
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
    

    for (RNDBindingProcessor *binding in _boundProcessorArguments) {
        NSError *passedInError;
        BOOL unbindingResult = [binding unbind:&passedInError];
        if (unbindingResult == NO) {
            result = NO;
            [underlyingErrorsArray addObject:passedInError];
        }
    }
    _boundProcessorArguments = nil;
    
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
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    dispatch_barrier_sync(_syncQueue, ^{
        [self unbindObjects:NULL];
    });
    dispatch_semaphore_signal(_syncCoordinator);
}

- (BOOL)unbind:(NSError * _Nullable __autoreleasing *)error {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        result = [self unbindObjects:error];
    });
    dispatch_semaphore_signal(_syncCoordinator);
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
        [self.binder updateBindingObjectValue];
    }
}

@end
