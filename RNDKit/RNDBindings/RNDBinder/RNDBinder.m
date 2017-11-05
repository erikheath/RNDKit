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
@synthesize valueTransformerName = _valueTransformerName;
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

- (BOOL)valueAsBool {
    __block BOOL value = NO;
    dispatch_sync(_syncQueue, ^{
        if ([self.bindingObjectValue respondsToSelector:@selector(boolValue)] == YES) {
            value = [self.bindingObjectValue boolValue];
        }
    });
    return value;
}

- (NSInteger)valueAsInteger {
    __block NSInteger value = 0;
    dispatch_sync(_syncQueue, ^{
        if ([self.bindingObjectValue respondsToSelector:@selector(integerValue)] == YES) {
            value = [self.bindingObjectValue integerValue];
        }
    });
    return value;
}

- (long)valueAsLong {
    __block long value = 0;
    dispatch_sync(_syncQueue, ^{
        if ([self.bindingObjectValue respondsToSelector:@selector(longValue)] == YES) {
            value = [self.bindingObjectValue longValue];
        }
    });
    return value;
}

- (float)valueAsFloat {
    __block float value = 0.0;
    dispatch_sync(_syncQueue, ^{
        if ([self.bindingObjectValue respondsToSelector:@selector(floatValue)] == YES) {
            value = [self.bindingObjectValue floatValue];
        }
    });
    return value;
}

- (double)valueAsDouble {
    __block double value = 0.0;
    dispatch_sync(_syncQueue, ^{
        if ([self.bindingObjectValue respondsToSelector:@selector(doubleValue)] == YES) {
            value = [self.bindingObjectValue doubleValue];
        }
    });
    return value;
}

- (NSString *)valueAsString {
    __block NSString *value = nil;
    dispatch_sync(_syncQueue, ^{
        if (self.bindingObjectValue == [NSNull null]) {
            value = nil;
        } else if ([self.bindingObjectValue isKindOfClass:[NSString class]] == YES) {
            value = self.bindingObjectValue;
        } else if ([self.bindingObjectValue respondsToSelector:@selector(stringValue)] == YES) {
            value = [self.bindingObjectValue stringValue];
        } else {
            value = [self.bindingObjectValue description];
        }
    });
    return value ;
}

- (NSDate *)valueAsDate {
    __block NSDate *value = nil;
    dispatch_sync(_syncQueue, ^{
        if (self.bindingObjectValue == [NSNull null]) {
            value = nil;
        } else if ([self.bindingObjectValue isKindOfClass:[NSDate class]] == YES) {
            value = self.bindingObjectValue;
        } else if ([self.bindingObjectValue isKindOfClass:[NSString class]] == YES) {
            value = [[[NSDateFormatter alloc] init] dateFromString:self.bindingObjectValue];
        } else {
            value = nil;
        }
    });
    return value;
}

- (NSUUID *)valueAsUUID {
    __block NSUUID *value = nil;
    dispatch_sync(_syncQueue, ^{
        if (self.bindingObjectValue == [NSNull null]) {
            value = nil;
        } else if ([self.bindingObjectValue isKindOfClass:[NSUUID class]] == YES) {
            value = self.bindingObjectValue;
        } else if ([self.bindingObjectValue isKindOfClass:[NSString class]] == YES) {
            value = [[NSUUID alloc] initWithUUIDString:self.bindingObjectValue];
        } else {
            value = nil;
        }
    });
    return value;
}

- (NSData *)valueAsData {
    __block NSData *value = nil;
    dispatch_sync(_syncQueue, ^{
        if (self.bindingObjectValue == [NSNull null]) {
            value = nil;
        } else if ([self.bindingObjectValue isKindOfClass:[NSData class]] == YES) {
            value = self.bindingObjectValue;
        } else {
            value = nil;
        }
    });
    return value;
}

- (id)valueAsObject {
    return self.bindingObjectValue;
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
        if (_observerKey == nil && [observedObjectValue isEqual:_observer.valueAsObject] == NO) {
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

