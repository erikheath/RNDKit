//
//  RNDCoordinatedDictionary.m
//  RNDKit
//
//  Created by Erikheath Thomas on 2/6/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDCoordinatedDictionary.h"
#import "RNDBindingMacros.h"
#import "RNDBindingConstants.h"

@interface RNDCoordinatedDictionary ()

@property (readwrite) BOOL bound;

@end

@implementation RNDCoordinatedDictionary

#pragma mark - Subclass Overrides
- (instancetype)initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    if ((self = [super initWithObjects:objects forKeys:keys count:cnt]) != nil) {
        _syncCoordinator = dispatch_semaphore_create(1);
        _coordinatorLock = [NSRecursiveLock new];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _syncCoordinator = dispatch_semaphore_create(1);
        _coordinatorLock = [NSRecursiveLock new];
    }
    return self;
}

- (NSUInteger)count {
    [_coordinatorLock lock];
    NSUInteger localObject = [super count];
    [_coordinatorLock unlock];
    return localObject;
}

- (id)objectForKey:(id)aKey {
    [_coordinatorLock lock];
    id  localObject = [super objectForKey:aKey];
    [_coordinatorLock unlock];
    return localObject;
}

- (NSEnumerator *)keyEnumerator {
    [_coordinatorLock lock];
    id localObject = [super keyEnumerator];
    [_coordinatorLock unlock];
    return localObject;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [_coordinatorLock lock];
    if (self.bound == YES) { return; }
    [super setObject:anObject forKey:aKey];
    [_coordinatorLock unlock];
}

- (void)removeObjectForKey:(id)aKey {
    [_coordinatorLock lock];
    if (self.bound == YES) { return; }
    [super removeObjectForKey:aKey];
    [_coordinatorLock unlock];
}


#pragma mark - RNDBindingObject Protocol

@synthesize syncCoordinator = _syncCoordinator;
@synthesize coordinatorLock = _coordinatorLock;

RNDCoordinatedProperty(BOOL, bound, Bound);

- (void)bind {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    [_coordinatorLock lock];
    [self bindCoordinatedObjects:nil];
    [_coordinatorLock unlock];
    dispatch_semaphore_signal(_syncCoordinator);
}

- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    [_coordinatorLock lock];
    BOOL result = [self bindCoordinatedObjects:error];
    [_coordinatorLock unlock];
    dispatch_semaphore_signal(_syncCoordinator);
    return result;
}

- (void)unbind {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    [_coordinatorLock lock];
    [self unbindCoordinatedObjects:nil];
    [_coordinatorLock unlock];
    dispatch_semaphore_signal(_syncCoordinator);
}

- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    [_coordinatorLock lock];
    BOOL result = [self unbindCoordinatedObjects:error];
    [_coordinatorLock unlock];
    dispatch_semaphore_signal(_syncCoordinator);
    return result;
}

- (BOOL)bindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error {
    
    BOOL result = YES;
    NSError *internalError = nil;
    
    if (_bound == YES) {
        result = NO;
        if (error != NULL) {
            NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
            internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                code:RNDObjectIsBoundError
                                            userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundErrorKey, nil, errorBundle, @"The coordinated dictionary is already bound.", @"The coordinated dictionary is already bound."),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundRecoverySuggestionErrorKey, nil, errorBundle, @"The coordinated dictionary is already bound. To rebind, call unbind first.", @"Attempted to rebind the coordinated dictionary.")
                                                       }];
            *error = internalError;
        }
        return result;
    }
    
    for (id<RNDBindingObject> bindingObject in self.allValues) {
        if ((result = [bindingObject bind:&internalError]) == YES) { continue; }
        [self unbind:NULL];
        if (error != NULL) { *error = internalError; }
        break;
    }
    
    _bound = result;
    return result;
}

- (BOOL)unbindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error {
    
    BOOL result = YES;
    id underlyingError;
    NSMutableArray *underlyingErrorsArray = [NSMutableArray array];
    NSError * internalError;
        
    for (id<RNDBindingObject> bindingObject in self.allValues) {
        NSError *passedInError;
        BOOL unbindingResult = [bindingObject unbind:&passedInError];
        if (unbindingResult == NO) {
            result = NO;
            [underlyingErrorsArray addObject:passedInError];
        }
    }
    
    if (error != NULL && (underlyingErrorsArray.count > 0 || underlyingError != nil)) {
        NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
        internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                            code:RNDProcessorIsNotRegisteredAsObserver
                                        userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDUnbindingErrorKey, nil, errorBundle, @"Unbinding Error", @"Unbinding Error"),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDUnbindingUnregistrationErrorKey, nil, errorBundle, @"An error occurred during unbinding.", @"An error occurred during unbinding."),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDUnbindingGenericRecoverySuggestionErrorKey, nil, errorBundle, @"An error occurred during unbinding. See the underlying error for more information and to trace the cause of the error.", @"An error occurred during unbinding."),
                                                   NSUnderlyingErrorKey:underlyingError,
                                                   RNDUnderlyingErrorsArrayKey: underlyingErrorsArray
                                                   }];
        *error = internalError;
    }
    
    _bound = NO;
    return result;
}

@end
