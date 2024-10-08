//
//  RNDBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinder.h"
#import "RNDBindingProcessor.h"
#import <objc/runtime.h>

@interface RNDBinder()

@end

@implementation RNDBinder

@synthesize boundOutflowProcessors = _boundOutflowProcessors;

@synthesize inflowProcessor = _inflowProcessor;

- (void)setInflowProcessor:(RNDBindingProcessor *)inflowProcessor {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.bound == YES) { return; }
        _inflowProcessor = inflowProcessor;
    });
}

- (NSMutableArray<RNDBindingProcessor *> *)inflowProcessor {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _inflowProcessor;
    });
    return localObject;
}

@synthesize outflowProcessors = _outflowProcessors;

- (NSMutableArray<RNDBindingProcessor *> *)outflowProcessors {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _outflowProcessors;
    });
    return localObject;
}


@synthesize bindingName = _bindingName;

- (void)setBindingName:(NSString * _Nonnull)bindingName {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.bound == YES) { return; }
        _bindingName = bindingName;
    });
}

- (NSString *)bindingName {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _bindingName;
    });
    return localObject;
}


@synthesize bindingObject = _bindingObject;

- (void)setBindingObject:(NSObject<RNDBindableObject> *)observer {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.bound == YES) { return; }
        _bindingObject = observer;
    });
}

- (NSObject<RNDBindableObject> *)bindingObject {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _bindingObject;
    });
    return localObject;
}


@synthesize bindingObjectKeyPath = _bindingObjectKeyPath;

- (void)setBindingObjectKeyPath:(NSString * _Nonnull)observerKey {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.bound == YES) { return; }
        _bindingObjectKeyPath = observerKey;
    });
}

- (NSString *)bindingObjectKeyPath {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _bindingObjectKeyPath;
    });
    return localObject;
}

@synthesize monitorsBindingObject = _monitorsBindingObject;

- (void)setMonitorsBindingObject:(BOOL)monitorsObserver {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.bound == YES) { return; }
        _monitorsBindingObject = monitorsObserver;
    });
}

- (BOOL)monitorsBindingObject {
    BOOL __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _monitorsBindingObject;
    });
    return localObject;
}


#pragma mark - Transient (Calculated) Properties
//@synthesize coordinator = _coordinator;
@synthesize coordinatorQueueIdentifier = _coordinatorQueueIdentifier;
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
    
    dispatch_sync(_coordinator, ^{
        objectValue = [self coordinatedBindingValue];
    });
    
    dispatch_semaphore_signal(_syncCoordinator);
    
    return objectValue;

}

#pragma mark - Value Management Methods

- (id _Nullable)coordinatedBindingValue {
    //Check the queue
    dispatch_assert_queue_debug(_coordinator);
    
    id objectValue = nil;
    
    // Set the runtime arguments
    NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
    NSDictionary *contextDictionary = (dispatch_get_context(_coordinator) != NULL ? (__bridge NSDictionary *)(dispatch_get_context(_coordinator)) : nil);
    if (contextDictionary != nil) {
        [arguments addEntriesFromDictionary:contextDictionary];
    }
    _inflowProcessor.runtimeArguments = [NSDictionary dictionaryWithDictionary:arguments];
    
    // Get the binding value
    objectValue = [self rawBindingValue];
    objectValue = [self calculatedBindingValue: objectValue];
    objectValue = [self filteredBindingValue:objectValue];
    objectValue = [self transformedBindingValue:objectValue];
    objectValue = [self wrappedBindingValue:objectValue];
    
    return objectValue;
}

- (id _Nullable)rawBindingValue {
    id objectValue = nil;
    NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
    NSDictionary *contextDictionary = (dispatch_get_context(_coordinator) != NULL ? (__bridge NSDictionary *)(dispatch_get_context(_coordinator)) : nil);
    if (contextDictionary != nil) {
        [arguments addEntriesFromDictionary:contextDictionary];
    }
    _inflowProcessor.runtimeArguments = [NSDictionary dictionaryWithDictionary:arguments];
    objectValue = _inflowProcessor.bindingValue;
    
    return objectValue;
}

- (id _Nullable)calculatedBindingValue:(id _Nullable)bindingValue {
    return bindingValue;
}

- (id _Nullable)filteredBindingValue:(id _Nullable)bindingValue {
    return bindingValue;
}

- (id _Nullable)transformedBindingValue:(id _Nullable)bindingValue {
    return bindingValue;
}

- (id _Nullable)wrappedBindingValue:(id)bindingValue {
    return bindingValue;
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
        
        [self updateObservedObjectValue:nil]; // TODO: Determine
        
    }
    
}

- (void)bindingObjectValueNeedsUpdate {
    dispatch_barrier_async(_coordinator, ^{
        [self updateCoordinatedBindingObjectValue:[self coordinatedBindingValue]];
    });
}

- (id)updateBindingObjectValue {
    id __block coordinatedValue = nil;
    dispatch_barrier_sync(_coordinator, ^{
        coordinatedValue = [self coordinatedBindingValue];
        [self updateCoordinatedBindingObjectValue:coordinatedValue];
    });
    return coordinatedValue;
}

- (void)updateCoordinatedBindingObjectValue:(id)coordinatedValue {
    // Because this may be a UI object, this last unit of work must be performed on the main queue.
    // This will serialize the work which removes the need for a barrier
    if (_bindingObjectKeyPath != nil && [coordinatedValue isEqual:[_bindingObject valueForKey:_bindingObjectKeyPath]] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_bindingObject setValue:coordinatedValue forKeyPath:_bindingObjectKeyPath];
        });
    }
    
    return;
}

#pragma mark RNDEditor



// TODO: Rewrite to account for editing, sync and async
- (BOOL)updateObservedObjectValue:(NSError * __autoreleasing _Nullable * _Nullable)error {
    //    NSError * __block internalError;
    //    NSMutableArray * __block internalErrorArray = [NSMutableArray new];
    dispatch_barrier_async(_coordinator, ^{
        // Get the current value of the bindingObject
        __block id bindingObjectValue = nil;
        dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
            bindingObjectValue = [_bindingObject valueForKeyPath:_bindingObjectKeyPath];
        });
        dispatch_async(dispatch_get_main_queue(), block);
        dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
        
        // Set the runtime arguments
        NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
        NSDictionary *contextDictionary = (dispatch_get_context(_coordinator) != NULL ? (__bridge NSDictionary *)(dispatch_get_context(_coordinator)) : nil);
        if (contextDictionary != nil) {
            [arguments addEntriesFromDictionary:contextDictionary];
        }
        [arguments setObject:bindingObjectValue forKey:RNDBinderObjectValue];
        for (RNDBindingProcessor *processor in _boundOutflowProcessors) {
            processor.runtimeArguments = [NSDictionary dictionaryWithDictionary:arguments];
            id processorBindingValue = processor.bindingValue;
            id __block observedObjectBindingValue = nil;
            if (processor.readOnMainQueue == YES) {
                dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
                    observedObjectBindingValue = [processor.observedObject valueForKeyPath:processor.resolvedObservedObjectKeyPath];
                });
                dispatch_async(dispatch_get_main_queue(), block);
                dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
            } else {
                observedObjectBindingValue = [processor.observedObject valueForKeyPath:processor.resolvedObservedObjectKeyPath];
            }
            
            // If the two values are equal, nothing needs to be updated.
            if ([processorBindingValue isEqual:observedObjectBindingValue] == YES) { return; }
            
            // Update the value of the observed object.
            // If the destination provides validation methods and validates immediately is
            // set to yes, then validate prior to writing. Otherwise, just write the value to the
            // key.
            // TODO: Add validation
            if (processor.writeOnMainQueue == YES) {
                dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
                    [processor.observedObject setValue:processorBindingValue forKeyPath:processor.resolvedObservedObjectKeyPath];
                });
                dispatch_async(dispatch_get_main_queue(), block);
                dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
            } else {
                [processor.observedObject setValue:processorBindingValue forKeyPath:processor.resolvedObservedObjectKeyPath];
            }
        }
        
    });
    return NO; // TODO: Fix
}

// TODO: Fix this up

// These are the methods that editors (views) should call on their binders when changes occur? Or, these are the methods that a binder implements when it is observing changes in a view.
- (void)editorDidBeginEditingBoundValue:(id _Nullable)value {
    
} // Editor (view) notifies binder of a pending value change.

- (void)editorDidEndEditingBoundValue:(id _Nullable)value {
    
} // Editor (view) notifies binder that a value change happened.

// These are the methods that datasources should call on their editors when specific key paths change.
- (void)dataSourceWillChangeEditedValue:(id _Nullable)value forKeyPath:(NSString * _Nonnull)keyPath {
    
} // Tells the editor that the value in the model will change while an edit in is progress.

- (void)dataSourceDidChangeEditedValue:(id _Nullable)value forKeyPath:(NSString * _Nonnull)keyPath {
    
} // Tells the editor that the value in the model will change while an edit is in progress.

// This is the method that a binder will call on a delegate or itself to determine how to behave in this situation. This is particularly useful when commitBoundEditWithDelegate is called because the delegate can intervene and determine the outcome.
- (BOOL)editedValue:(id _Nullable)editedValue shouldChangeToValue:(id _Nullable)newValue fromDataSourceValue:(id _Nullable)dataSourceValue {
    return NO;
} // If an optimistic locking failure has occurred where the current model value does not match the edited value, provides the binder with an opportunity to confirm that the change should occur.



- (void)discardBoundEdit {
    // If the observer (binding object) maintains an in process edit, call the discardBoundEdit method.
    // Otherwise, simply reset the value to the model value.
    if ([_bindingObject conformsToProtocol:@protocol(RNDEditor)] == YES && [_bindingObject respondsToSelector:@selector(discardBoundEdit)] == YES) {
        dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
            [((id<RNDEditor>)_bindingObject) discardBoundEdit];

        });
        dispatch_async(dispatch_get_main_queue(), block);
        dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
    }
    [self bindingObjectValueNeedsUpdate];
}
- (BOOL)commitBoundEdit {
    return [self commitBoundEditAndReturnError:NULL];
}

- (BOOL)commitBoundEditAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [self updateObservedObjectValue:error];
    
}

- (void)commitBoundEditWithDelegate:(nullable id<RNDEditorDelegate>)delegate contextInfo:(nullable void *)contextInfo {
    
}


#pragma mark - Object Lifecycle

- (instancetype _Nullable)init {
    if ((self = [super init]) != nil) {
        
        _coordinatorQueueIdentifier = [[NSUUID alloc] init];
        _coordinator = dispatch_queue_create([[_coordinatorQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        _syncCoordinator = dispatch_semaphore_create(1);

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
                [propertyName isEqualToString:@"coordinatorQueueIdentifier"] ||
                [propertyName isEqualToString:@"syncCoordinator"]) { continue; }
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
        _coordinatorQueueIdentifier = [[NSUUID alloc] init];
        _coordinator = dispatch_queue_create([[_coordinatorQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        _syncCoordinator = dispatch_semaphore_create(1);


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
                [propertyName isEqualToString:@"coordinatorQueueIdentifier"] ||
                [propertyName isEqualToString:@"syncCoordinator"]) { continue; }
            [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
        }
        
        if (propertyCount > 0) {
            free(properties);
        }
}

#pragma mark - Binding Management

- (BOOL)bindCoordinatedObjects:(NSError *__autoreleasing  _Nullable *)error {
    BOOL result = YES;
    NSError *internalError = nil;
    
    dispatch_assert_queue_debug(_coordinator);

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
    
    if (_monitorsBindingObject == YES) {
        if (_bindingObject == nil) {
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
        } else if ([_bindingObject isKindOfClass:[RNDBindingProcessor class]] == YES) {
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
            
        } else if (_bindingObjectKeyPath == nil) {
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
        
        [_bindingObject addObserver:self
                    forKeyPath:_bindingObjectKeyPath
                       options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior |  NSKeyValueObservingOptionOld)
                       context:(__bridge void * _Nullable)(_bindingName)];
    }
    
    // The processors must receive a bind message.
    _inflowProcessor.binder = self;
    if (_inflowProcessor != nil && [_inflowProcessor bind:error] == NO) {
        [self unbindCoordinatedObjects:error];
        return NO;
    }

    _boundOutflowProcessors = [NSArray arrayWithArray:_outflowProcessors];
    for (RNDBindingProcessor *processor in _boundOutflowProcessors) {
        processor.binder = self;
        if ([processor bind:error] == NO) {
            [self unbindCoordinatedObjects:error];
            return NO;
        }
    }

    _isBound = YES;
    return _isBound;
}

- (void)bind {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    dispatch_sync(_coordinator, ^{
        [self bindCoordinatedObjects:nil];
    });
    dispatch_semaphore_signal(_syncCoordinator);
}

- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    __block BOOL result = NO;
    dispatch_sync(_coordinator, ^{
        result = [self bindCoordinatedObjects:error];
    });
    dispatch_semaphore_signal(_syncCoordinator);
    return result;
}

- (BOOL)unbindCoordinatedObjects:(NSError * _Nullable __autoreleasing * _Nullable)error {
    BOOL result = YES;
    id underlyingError;
    NSMutableArray *underlyingErrorsArray = [NSMutableArray array];
    NSError * internalError;

    dispatch_assert_queue_debug(self.coordinator);
    
    @try {
        if (_isBound == YES && _monitorsBindingObject == YES) {
            [_bindingObject removeObserver:self
                           forKeyPath:_bindingObjectKeyPath
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
    
    NSError *passedInError;
    BOOL unbindingResult = [_inflowProcessor unbind:&passedInError];
    if (unbindingResult == NO) {
        result = NO;
        if (passedInError != nil) { [underlyingErrorsArray addObject:passedInError]; }
    }
    
    for (RNDBindingProcessor *processor in _boundOutflowProcessors) {
        unbindingResult = [processor unbind:&passedInError];
        if (unbindingResult == NO) {
            result = NO;
            if (passedInError != nil) { [underlyingErrorsArray addObject:passedInError]; }
        }
    }
    _boundOutflowProcessors = nil;
    
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
    dispatch_sync(_coordinator, ^{
        [self unbindCoordinatedObjects:nil];
    });
    dispatch_semaphore_signal(_syncCoordinator);
}

- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    __block BOOL result = NO;
    dispatch_sync(_coordinator, ^{
        result = [self unbindCoordinatedObjects:error];
    });
    dispatch_semaphore_signal(_syncCoordinator);
    return result;
}

@end

