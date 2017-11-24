//
//  RNDBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinder.h"
#import "RNDBinding.h"
#import "RNDPatternedBinding.h"
#import <objc/runtime.h>

@interface RNDBinder()

@property (strong, nullable, readonly) NSUUID *syncQueueIdentifier;
@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;
@property (readwrite, getter=isBound) BOOL bound;

@end

@implementation RNDBinder

#pragma mark - Properties

@synthesize bindings = _bindings;
@synthesize binderIdentifier = _binderIdentifier;
@synthesize observer = _observer;
@synthesize observerKey = _observerKey;
@synthesize binderMode = _binderMode;
@synthesize monitorsObserver = _monitorsObserver;
@synthesize syncQueue = _syncQueue;
@synthesize syncQueueIdentifier = _syncQueueIdentifier;
@synthesize bound = _bound;
@synthesize nullPlaceholder = _nullPlaceholder;
@synthesize multipleSelectionPlaceholder = _multipleSelectionPlaceholder;
@synthesize noSelectionPlaceholder = _noSelectionPlaceholder;
@synthesize notApplicablePlaceholder = _notApplicablePlaceholder;
@synthesize nilPlaceholder = _nilPlaceholder;
@synthesize serializerQueue = _serializerQueue;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize filtersNilValues = _filtersNilValues;
@synthesize filtersMarkerValues = _filtersMarkerValues;
@synthesize mutuallyExclusive = _mutuallyExclusive;
@synthesize unwrapSingleValue = _unwrapSingleValue;


- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        if (self.isBound == NO) {
            objectValue = nil;
        }
        
        NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:_binderValues.count];
        
        [_binderValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
            NSDictionary *contextDictionary = (dispatch_get_context(self.syncQueue) != NULL ? (__bridge NSDictionary *)(dispatch_get_context(self.syncQueue)) : nil);
            if (contextDictionary != nil) {
                [arguments addEntriesFromDictionary:contextDictionary];
            }
            [arguments setObject:@(idx) forKey:RNDIterationArgument];
            ((RNDBinding *)obj).runtimeArguments = [NSDictionary dictionaryWithDictionary:arguments];
            
            id rawObjectValue = ((RNDBinding *)obj).bindingObjectValue;
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

            NSString *entryString = ((RNDBinding *)obj).userString.bindingObjectValue;
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
        [self.bindings.firstObject setBindingObjectValue:objectValue];
    });
}

#pragma mark - Object Lifecycle

- (instancetype _Nullable)init {
    return [self initWithCoder:nil];
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

- (BOOL)bind:(NSError *__autoreleasing  _Nullable *)error {
    __block NSError * internalError = nil;
    __block BOOL success = NO;
    
    dispatch_barrier_sync(_syncQueue, ^{
        if (_observer == nil) {
            // TODO: Set the internal error.
            success = NO;
            return;
        }
        if (_monitorsObserver == YES) {
            [_observer addObserver:self
                        forKeyPath:_observerKey
                           options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld)
                           context:(__bridge void * _Nullable)(_binderIdentifier)];
        }
        for (RNDBinding *binding in _bindings) {
            [binding bind];
        }
        success = YES;
    });
    self.bound = success;
    return success;
}

- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __block NSError * internalError = nil;
    __block BOOL success = NO;
    
    dispatch_barrier_sync(_syncQueue, ^{
        if (_observer == nil) {
            // TODO: Set the internal error.
            success = NO;
            return;
        }
        for (RNDBinding *binding in _bindings) {
            [binding unbind];
        }
        if (_bound == YES) {
            [_observer removeObserver:self
                           forKeyPath:_observerKey
                              context:(__bridge void * _Nullable)(_binderIdentifier)];
        }
        success = YES;
    });
    self.bound = NO;
    return success;
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
        
        if ([self.bindings.firstObject.bindingObjectValue isEqual:observerObjectValue] == YES) { return; }
        
        [self.bindings.firstObject setBindingObjectValue:observerObjectValue];
    });
}


@end

