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
@property (readwrite, getter=isBound) BOOL bound;

@end

@implementation RNDBinder

#pragma mark - Properties

@synthesize inflowBindings = _inflowBindings;

- (void)setBindings:(NSArray<RNDBindingProcessor *> * _Nonnull)bindings {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _inflowBindings = bindings;
    });
}

- (NSString *)inflowBindings {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _inflowBindings;
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
@synthesize bound = _bound;
@synthesize serializerQueue = _serializerQueue;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        if (self.isBound == NO) {
            objectValue = nil;
        }
        
        NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:_inflowBindings.count];
        
        [_inflowBindings enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
            case valueOnlyMode:
            {
                NSMutableArray *valueOnlyArray = [NSMutableArray arrayWithCapacity:valuesArray.count];
                for (NSDictionary *dictionary in valuesArray) {
                    [valueOnlyArray addObjectsFromArray:[dictionary allValues]];
                }
                objectValue = _unwrapSingleValue == YES ? (valueOnlyArray.count == 1 ? valueOnlyArray.firstObject : valueOnlyArray) : valueOnlyArray;
                break;
            }
            case keyedValueMode:
            {
                NSMutableDictionary *keyedValueDictionary = [NSMutableDictionary dictionaryWithCapacity:valuesArray.count];
                for (NSDictionary *dictionary in valuesArray) {
                    [keyedValueDictionary addEntriesFromDictionary:dictionary];
                }
                objectValue = keyedValueDictionary;
                break;
            }
            case orderedKeyedValueMode:
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
    return [super init];
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
    
    dispatch_assert_queue_barrier(self.syncQueue);

    if (_observer == nil) {
        // TODO: Set the internal error.
        _bound = NO;
        return _bound;
    }
    if (_monitorsObserver == YES) {
        [_observer addObserver:self
                    forKeyPath:_observerKey
                       options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior |  NSKeyValueObservingOptionOld)
                       context:(__bridge void * _Nullable)(_binderIdentifier)];
    }
    for (RNDBindingProcessor *binding in _inflowBindings) {
        if ([binding bindObjects:error] == YES) { continue; }
        [self unbindObjects:error];
        return NO;
    }
    
    _bound = YES;
    return _bound;
}

- (void)bind {
    dispatch_barrier_async(_syncQueue, ^{
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

    dispatch_assert_queue_barrier(self.syncQueue);

    if (_observer == nil) {
        // TODO: Set the internal error.
        _bound = NO;
        return _bound;
    }
    for (RNDBindingProcessor *binding in _inflowBindings) {
        [binding unbindObjects:error];
    }
    if (_monitorsObserver == YES) {
        [_observer removeObserver:self
                       forKeyPath:_observerKey
                          context:(__bridge void * _Nullable)(_binderIdentifier)];
    }
    
    _bound = NO;
    return _bound;
}

- (void)unbind {
    dispatch_barrier_async(_syncQueue, ^{
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

