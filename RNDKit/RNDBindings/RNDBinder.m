//
//  RNDBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinder.h"
#import "RNDBinding.h"
#import <objc/runtime.h>

@interface RNDBinder()

@property (strong, nullable, readonly) NSUUID *syncQueueIdentifier;
@property (readwrite, getter=isBound) BOOL bound;

@end

@implementation RNDBinder

#pragma mark - Properties

@synthesize bindings = _bindings;
@synthesize binderIdentifier = _binderIdentifier;
@synthesize observer = _observer;
@synthesize observerKey = _observerKey;
@synthesize binderMode = _binderMode;
@synthesize monitorsObservable = _monitorsObservable;
@synthesize monitorsObserver = _monitorsObserver;
@synthesize syncQueue = _syncQueue;
@synthesize syncQueueIdentifier = _syncQueueIdentifier;
@synthesize bound = _bound;
@synthesize nullPlaceholder = _nullPlaceholder;
@synthesize multipleSelectionPlaceholder = _multipleSelectionPlaceholder;
@synthesize noSelectionPlaceholder = _noSelectionPlaceholder;
@synthesize notApplicablePlaceholder = _notApplicablePlaceholder;

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
    // Must be overridden by subclasses to actually do anything.
}


@end

