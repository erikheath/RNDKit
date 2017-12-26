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

@end

@implementation RNDBinder

@synthesize inflowProcessor = _inflowProcessor;

- (void)setInflowProcessor:(RNDBindingProcessor *)inflowProcessor {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _inflowProcessor = inflowProcessor;
    });
}

- (NSMutableArray<RNDBindingProcessor *> *)inflowProcessor {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _inflowProcessor;
    });
    return localObject;
}

@synthesize outflowProcessor = _outflowProcessor;

- (void)setOutflowProcessor:(RNDBindingProcessor *)outflowProcessor {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _outflowProcessor = outflowProcessor;
    });
}

- (NSMutableArray<RNDBindingProcessor *> *)outflowProcessor {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _outflowProcessor;
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


@synthesize boundObject = _boundObject;

- (void)setBoundObject:(NSObject<RNDBindableObject> *)observer {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _boundObject = observer;
    });
}

- (NSObject<RNDBindableObject> *)boundObject {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _boundObject;
    });
    return localObject;
}


@synthesize boundObjectKey = _boundObjectKey;

- (void)setBoundObjectKey:(NSString * _Nonnull)observerKey {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _boundObjectKey = observerKey;
    });
}

- (NSString *)boundObjectKey {
    id __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _boundObjectKey;
    });
    return localObject;
}

@synthesize monitorsBoundObject = _monitorsBoundObject;

- (void)setMonitorsBoundObject:(BOOL)monitorsObserver {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _monitorsBoundObject = monitorsObserver;
    });
}

- (BOOL)monitorsBoundObject {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _monitorsBoundObject;
    });
    return localObject;
}


#pragma mark - Transient (Calculated) Properties
@synthesize syncQueue = _syncQueue;
@synthesize syncQueueIdentifier = _syncQueueIdentifier;
@synthesize bound = _isBound;

- (id _Nullable)bindingObjectValue {
    dispatch_assert_queue_barrier_debug(_syncQueue);

    id objectValue = nil;
    
    if (_isBound == NO) {
        objectValue = nil;
        return objectValue;
    }
    
    NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
    NSDictionary *contextDictionary = (dispatch_get_context(_syncQueue) != NULL ? (__bridge NSDictionary *)(dispatch_get_context(_syncQueue)) : nil);
    if (contextDictionary != nil) {
        [arguments addEntriesFromDictionary:contextDictionary];
    }
    _inflowProcessor.runtimeArguments = [NSDictionary dictionaryWithDictionary:arguments];
    objectValue = _inflowProcessor.bindingObjectValue;
    
    return objectValue;
}

- (id _Nullable)bindingValue {
    id __block objectValue = nil;
    
    dispatch_sync(_syncQueue, ^{
        objectValue = self.bindingObjectValue;
    });
    return objectValue;

}

- (void)setBindingObjectValue:(id)bindingObjectValue {
    dispatch_assert_queue_debug(_syncQueue);

    // There may be no actual change, in which case nothing needs to happen.
    id objectValue = bindingObjectValue;
    if ([self.bindingObjectValue isEqual:objectValue]) { return; }

    NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
    NSDictionary *contextDictionary = (dispatch_get_context(_syncQueue) != NULL ? (__bridge NSDictionary *)(dispatch_get_context(_syncQueue)) : nil);
    if (contextDictionary != nil) {
        [arguments addEntriesFromDictionary:contextDictionary];
    }
    [arguments setObject:bindingObjectValue forKey:RNDBinderObjectValue];
    _outflowProcessor.runtimeArguments = [NSDictionary dictionaryWithDictionary:arguments];
    [_outflowProcessor setBindingObjectValue:objectValue];

}

- (void)setBindingValue:(id)bindingValue {
    dispatch_async(_syncQueue, ^{
        [self setBindingObjectValue:bindingValue];
    });
}
#pragma mark - Object Lifecycle

- (instancetype _Nullable)init {
    if ((self = [super init]) != nil) {
        
        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
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
    
    if (_monitorsBoundObject == YES) {
        if (_boundObject == nil) {
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
        } else if ([_boundObject isKindOfClass:[RNDBindingProcessor class]] == YES) {
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
            
        } else if (_boundObjectKey == nil) {
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
        } else if (_bindingName == nil) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDKeyValuePathError
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDBindingNameIsNilErrorKey, nil, errorBundle, @"The binder binding name is nil.", @"The binder binding name is nil."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectRecoverySuggestionErrorKey, nil, errorBundle, @"A binding name must be provided when monitoring the observer./n/nIf you are using the RNDWorkbench, add a binding name or check or check the Use Default Name checkbox in the Binder Properties.", @"The binder's binding name is nil and will prevent the observer object from being KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;
        }
        
        [_boundObject addObserver:self
                    forKeyPath:_boundObjectKey
                       options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior |  NSKeyValueObservingOptionOld)
                       context:(__bridge void * _Nullable)(_bindingName)];
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
        if (_isBound == YES && _monitorsBoundObject == YES) {
            [_boundObject removeObserver:self
                           forKeyPath:_boundObjectKey
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
    } else if ([(__bridge NSString * _Nonnull)(context) isKindOfClass: [NSString class]] == NO || [(__bridge NSString * _Nonnull)(context) isEqualToString:_bindingName] == NO) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if (change[NSKeyValueChangeNotificationIsPriorKey] != nil) {
        // Add delegate calls?
    } else {
        // Add delegate calls?
        
        [self updateValueOfObservedObject];
        
    }
    
}

- (void)updateBindingObjectValue {
    // Because this may be a UI object, this last unit of work must be performed on the main queue.
    // This will serialize the work which removes the need for a barrier
    dispatch_async(_syncQueue, ^{
        id observedObjectValue = self.bindingObjectValue;
        if (_boundObjectKey != nil && [observedObjectValue isEqual:[_boundObject valueForKey:_boundObjectKey]] == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_boundObject setValue:observedObjectValue forKeyPath:_boundObjectKey];
            });
            return;
        }
    });
}

- (void)updateValueOfObservedObject {
    dispatch_async(_syncQueue, ^{
        __block id observerObjectValue = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            observerObjectValue = [_boundObject valueForKeyPath:_boundObjectKey];
        });
        [_outflowProcessor setBindingObjectValue:observerObjectValue];
    });
}


@end

