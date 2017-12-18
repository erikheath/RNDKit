//
//  RNDBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinder.h"
#import "RNDBindingProcessor.h"
#import "RNDPatternedStringProcessor.h"
#import <objc/runtime.h>

@interface RNDBinder()

@property (strong, nullable, readonly) NSUUID *syncQueueIdentifier;
@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;

@end

@implementation RNDBinder

#pragma mark - Properties

@synthesize inflowBindings = _inflowBindings;

- (NSMutableArray<RNDBindingProcessor *> *)inflowBindings {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _inflowBindings;
    });
    return localObject;
}

@synthesize boundInflowBindings = _boundInflowBindings;

- (NSArray<RNDBindingProcessor *> *)boundInflowBindings {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _boundInflowBindings;
    });
    return localObject;
}

@synthesize outflowBindings = _outflowBindings;

- (NSMutableArray<RNDBindingProcessor *> *)outflowBindings {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _outflowBindings;
    });
    return localObject;
}

@synthesize boundOutflowBindings = _boundOutflowBindings;

- (NSArray<RNDBindingProcessor *> *)boundOutflowBindings {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _boundOutflowBindings;
    });
    return localObject;
}

@synthesize binderIdentifier = _binderIdentifier;

- (void)setBinderIdentifier:(NSString * _Nonnull)binderIdentifier {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _binderIdentifier = binderIdentifier;
    });
}

- (NSString *)binderIdentifier {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _binderIdentifier;
    });
    return localObject;
}

@synthesize bindingName = _bindingName;

- (void)setBindingName:(NSString * _Nonnull)bindingName {
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


@synthesize observer = _observer;

- (void)setObserver:(NSObject<RNDBindableObject> *)observer {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _observer = observer;
    });
}

- (NSObject<RNDBindableObject> *)observer {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _observer;
    });
    return localObject;
}


@synthesize observerKey = _observerKey;

- (void)setObserverKey:(NSString * _Nonnull)observerKey {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _observerKey = observerKey;
    });
}

- (NSString *)observerKey {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _observerKey;
    });
    return localObject;
}


@synthesize binderMode = _binderMode;

- (void)setBinderMode:(RNDBinderMode)binderMode {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _binderMode = binderMode;
    });
}

- (RNDBinderMode)binderMode {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _binderMode;
    });
    return localObject;
}


@synthesize monitorsObserver = _monitorsObserver;

- (void)setMonitorsObserver:(BOOL)monitorsObserver {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _monitorsObserver = monitorsObserver;
    });
}

- (BOOL)monitorsObserver {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _monitorsObserver;
    });
    return localObject;
}


@synthesize filtersNilValues = _filtersNilValues;

- (void)setFiltersNilValues:(BOOL)filtersNilValues {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _filtersNilValues = filtersNilValues;
    });
}

- (BOOL)filtersNilValues {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _filtersNilValues;
    });
    return localObject;
}


@synthesize filtersMarkerValues = _filtersMarkerValues;

- (void)setFiltersMarkerValues:(BOOL)filtersMarkerValues {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _filtersMarkerValues = filtersMarkerValues;
    });
}

- (BOOL)filtersMarkerValues {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _filtersMarkerValues;
    });
    return localObject;
}


@synthesize mutuallyExclusive = _mutuallyExclusive;

- (void)setMutuallyExclusive:(BOOL)mutuallyExclusive {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _mutuallyExclusive = mutuallyExclusive;
    });
}

- (BOOL)mutuallyExclusive {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _mutuallyExclusive;
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


#pragma mark - Transient (Calculated) Properties
@synthesize syncQueue = _syncQueue;
@synthesize syncQueueIdentifier = _syncQueueIdentifier;
@synthesize bound = _isBound;
@synthesize serializerQueue = _serializerQueue;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        if (self.isBound == NO) {
            objectValue = nil;
            return;
        }
        
        NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:_boundInflowBindings.count];
        
        [_boundInflowBindings enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
            NSDictionary *contextDictionary = (dispatch_get_context(self.syncQueue) != NULL ? (__bridge NSDictionary *)(dispatch_get_context(self.syncQueue)) : nil);
            if (contextDictionary != nil) {
                [arguments addEntriesFromDictionary:contextDictionary];
            }
            [arguments setObject:@(idx) forKey:RNDIterationArgument];
            ((RNDBindingProcessor *)obj).runtimeArguments = [NSDictionary dictionaryWithDictionary:arguments];
            
            id rawObjectValue = ((RNDBindingProcessor *)obj).bindingObjectValue;
            if ([rawObjectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                if (_filtersMarkerValues == YES) { return; }
                rawObjectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder.bindingObjectValue : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                if (_filtersMarkerValues == YES) { return; }
                rawObjectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder.bindingObjectValue : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                if (_filtersMarkerValues == YES) { return; }
                rawObjectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder.bindingObjectValue : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNullValueMarker] == YES) {
                if (_filtersMarkerValues == YES) { return; }
                rawObjectValue = self.nullPlaceholder != nil ? self.nullPlaceholder.bindingObjectValue : rawObjectValue;
            }
            
            if (rawObjectValue == nil) {
                if (_filtersMarkerValues == YES || _filtersNilValues == YES) { return; }
                rawObjectValue = self.nilPlaceholder != nil ? self.nilPlaceholder.bindingObjectValue : [NSNull null];
            }

            NSString *entryString = ((RNDBindingProcessor *)obj).userString.bindingObjectValue;
            [valuesArray addObject:@{entryString: rawObjectValue}];
            if (_mutuallyExclusive == YES) { *stop = YES; }
            
        }];

        
        switch (_binderMode) {
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
        
    });
    
    return objectValue;
}

- (void)setBindingObjectValue:(id)bindingObjectValue {
    dispatch_async(_serializerQueue, ^{
        // There may be no actual change, in which case nothing needs to happen.
        id objectValue = bindingObjectValue;
        if ([self.bindingObjectValue isEqual:objectValue]) { return; }
        for (RNDBindingProcessor *binding in self.outflowBindings) {
            [binding setBindingObjectValue:objectValue];
        }
    });
}

#pragma mark - Object Lifecycle

- (instancetype _Nullable)init {
    if ((self = [super init]) != nil) {
        _inflowBindings = [NSMutableArray array];
        _outflowBindings = [NSMutableArray array];
        
        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        
        _serializerQueueIdentifier = [[NSUUID alloc] init];
        _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (aDecoder == nil) {
        return nil;
    }
    if ((self = [super init]) != nil) {
        uint propertyCount;
        objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
            if ([propertyName isEqualToString:@"syncQueue"] ||
                [propertyName isEqualToString:@"observer"] ||
                [propertyName isEqualToString:@"syncQueueIdentifier"]) { continue; }
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);

        _serializerQueueIdentifier = [[NSUUID alloc] init];
        _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);

        if (propertyCount > 0) {
            free(properties);
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
                [propertyName isEqualToString:@"observer"] ||
                [propertyName isEqualToString:@"syncQueueIdentifier"]) { continue; }
            [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
        }
        
        if (propertyCount > 0) {
            free(properties);
        }
}

#pragma mark - Binding Management

- (BOOL)bindObjects:(NSError *__autoreleasing  _Nullable *)error {
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
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundErrorKey, nil, errorBundle, @"The binder is already bound.", @"The binder is already bound."),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundRecoverySuggestionErrorKey, nil, errorBundle, @"The binder is already bound. To rebind the binder, call unbind on the binder first.", @"Attempted to rebind the binder.")
                                                       }];
            *error = internalError;
        }
        return result;
    }
    
    if (_monitorsObserver == YES) {
        if (_observer == nil) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDObservedObjectIsNil
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDObserverObjectIsNilErrorKey, nil, errorBundle, @"The observer object is nil.", @"The observer object is nil."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectRecoverySuggestionErrorKey, nil, errorBundle, @"If loading from an archive, confirm that the binder set containing the binder has a valid observed object. Alternatively, confirm that the  binder set containing the binder references the correct binding Identifier in the Xib or Storyboard in the RNDWorkbench application and then regenerate the archive.\n\nIf not loading from an archive, confirm that the observer object is set prior to attempting to bind the binder.", @"The observer object is nil and can not be KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;
        } else if ([_observer isKindOfClass:[RNDBindingProcessor class]] == YES) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDAttemptToObserveProcessorError
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectErrorKey, nil, errorBundle, @"The observer object is a processor.", @"The observer object is a processor."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObserverObjectRecoverySuggestionErrorKey, nil, errorBundle, @"The binder has been set to monitor another processor. Processors can not be monitored. Change the monitors observer setting of this binder to false to correct this error./n/n If you are using the RNDWorkbench, uncheck the monitors observer checkbox for this binder.", @"The observer object is a processor and can not be KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;
            
        } else if (_observerKey == nil) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDKeyValuePathError
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDKeyPathIsNilErrorKey, nil, errorBundle, @"The observer object keypath is nil.", @"The observer object keypath is nil."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectRecoverySuggestionErrorKey, nil, errorBundle, @"A keypath corresponding to an observable relationship of an object must be specified to enable monitoring./n/nIf you are using the RNDWorkbench, either uncheck the monitors observer checkbox for this binder or specify an observable property keypath to monitor.", @"The keypath of the observer object is nil and will prevent the observer object from being KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;
        }
        
        [_observer addObserver:self
                    forKeyPath:_observerKey
                       options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior |  NSKeyValueObservingOptionOld)
                       context:(__bridge void * _Nullable)(_binderIdentifier)];
    }
    
    // The processors must receive a bind message.
    _boundInflowBindings = [NSArray arrayWithArray:_inflowBindings];
    for (RNDBindingProcessor *binding in _boundInflowBindings) {
        if ([binding bindObjects:error] == YES) { continue; }
        [self unbindObjects:error];
        return NO;
    }
    _boundOutflowBindings = [NSArray arrayWithArray:_outflowBindings];
    for (RNDBindingProcessor *binding in _boundOutflowBindings) {
        if ([binding bindObjects:error] == YES) { continue; }
        [self unbindObjects:error];
        return NO;
    }

    _isBound = YES;
    return _isBound;
}

- (void)bind {
    dispatch_barrier_sync(_syncQueue, ^{
        [self bindObjects:nil];
    });
}

- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        result = [self bindObjects:error];
    });
    return result;
}

- (BOOL)unbindObjects:(NSError * _Nullable __autoreleasing * _Nullable)error {
    BOOL result = YES;
    id underlyingError;
    NSMutableArray *underlyingErrorsArray = [NSMutableArray array];
    NSError * internalError;

    dispatch_assert_queue_barrier_debug(self.syncQueue);
    
    @try {
        if (_isBound == YES && _monitorsObserver == YES) {
            [_observer removeObserver:self
                           forKeyPath:_observerKey
                              context:(__bridge void * _Nullable)(_binderIdentifier)];
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
    
    for (RNDBindingProcessor *binding in _boundInflowBindings) {
        NSError *passedInError;
        BOOL unbindingResult = [binding unbindObjects:error];
        if (unbindingResult == NO) {
            result = NO;
            [underlyingErrorsArray addObject:passedInError];
        }
    }
    _boundInflowBindings = nil;

    for (RNDBindingProcessor *binding in _boundOutflowBindings) {
        NSError *passedInError;
        BOOL unbindingResult = [binding unbindObjects:error];
        if (unbindingResult == NO) {
            result = NO;
            [underlyingErrorsArray addObject:passedInError];
        }
    }
    _boundOutflowBindings = nil;

        
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
        [self unbindObjects:nil];
    });
}

- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        result = [self unbindObjects:error];
    });
    return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    if (context == NULL || context == nil) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    } else if ([(__bridge NSString * _Nonnull)(context) isKindOfClass: [NSString class]] == NO || [(__bridge NSString * _Nonnull)(context) isEqualToString:self.binderIdentifier] == NO) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if (change[NSKeyValueChangeNotificationIsPriorKey] != nil) {
        // Add delegate calls?
    } else {
        // Add delegate calls?
        
        [self updateValueOfObservedObject];
        
    }
    
}

- (void)updateValueOfObserverObject {
    // Because this may be a UI object, this last unit of work must be performed on the main queue.
    // This will serialize the work which removes the need for a barrier
    dispatch_barrier_async(_syncQueue, ^{
        id observedObjectValue = self.bindingObjectValue;
        if (_observerKey == nil && [observedObjectValue isEqual:_observer.bindingObjectValue] == NO) {
            // This is a value binding that uses the RNDConvertableValue protocol.
            dispatch_async(dispatch_get_main_queue(), ^{
                [_observer setBindingObjectValue:observedObjectValue];
            });
            return;
        } else if ([observedObjectValue isEqual:[_observer valueForKey:_observerKey]] == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_observer setValue:observedObjectValue forKeyPath:_observerKey];
            });
            return;
        }
    });
}

- (void)updateValueOfObservedObject {
    dispatch_barrier_async(self.syncQueue, ^{
        __block id observerObjectValue = nil;
        if (self.observerKey == nil) {
            // This is a value binding.
            dispatch_sync(dispatch_get_main_queue(), ^{
                observerObjectValue = [self.observer bindingObjectValue];
            });
        } else {
            // This is a property binding.
            dispatch_sync(dispatch_get_main_queue(), ^{
                observerObjectValue = [self.observer valueForKeyPath:self.observerKey];
            });
        }
        
        if ([self.inflowBindings.firstObject.bindingObjectValue isEqual:observerObjectValue] == YES) { return; }
        
        [self.inflowBindings.firstObject setBindingObjectValue:observerObjectValue];
    });
}


@end

