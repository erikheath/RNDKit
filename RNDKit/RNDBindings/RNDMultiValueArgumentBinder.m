//
//  RNDMultiValueArgumentBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValueArgumentBinder.h"
#import "RNDBinding.h"
#import "RNDInvocationBinding.h"
#import "RNDPredicateBinding.h"
#import "NSObject+RNDObjectBinding.h"
#import <objc/runtime.h>

@interface RNDMultiValueArgumentBinder ()

@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;
@property (nullable, readonly) SEL actionSelector;
@property (strong, nonnull, readonly) NSDictionary *substitutions;

@end

@implementation RNDMultiValueArgumentBinder

#pragma mark - Properties
@synthesize invocationArray = _invocationArray;
@synthesize serializerQueue = _serializerQueue;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize bindingInvocation = _bindingInvocation;
@synthesize unbindingInvocation = _unbindingInvocation;
@synthesize actionInvocation = _actionInvocation;
@synthesize mutuallyExclusive = _mutuallyExclusive;

- (id _Nullable)bindingObjectValue {
    NSMutableArray * __block objectValue = [NSMutableArray array];
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            objectValue = nil;
        }
        
        for (NSDictionary<RNDPredicateBinding *, RNDInvocationBinding *> *invocationDictionary in _invocationArray) {
            NSInvocation *invocation = nil;
            RNDPredicateBinding *predicateBinding = invocationDictionary.allKeys.firstObject;
            if (predicateBinding != nil && [predicateBinding.bindingObjectValue evaluateWithObject:predicateBinding.evaluatedObject] == NO) {
                continue;
            }
            RNDInvocationBinding *binding = invocationDictionary.allValues.firstObject;
            NSDictionary *contextDictionary = (dispatch_get_context(self.syncQueue) != NULL ? (__bridge NSDictionary *)(dispatch_get_context(self.syncQueue)) : nil);
            
            if (contextDictionary != nil) {
                dispatch_set_context(binding.serializerQueue, (__bridge void * _Nullable)(contextDictionary));
            }
            
            if ((invocation = binding.bindingObjectValue) != nil) {
                [objectValue addObject:invocation];
                dispatch_set_context(binding.serializerQueue, NULL);
                if (_mutuallyExclusive == YES) { break; }
                continue;
            }
            
            dispatch_set_context(binding.serializerQueue, NULL);
        }
    });
    
    return objectValue;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (aDecoder == nil) {
        return nil;
    }
    
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        uint propertyCount;
        objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
            if ([propertyName isEqualToString:@"serializerQueueIdentifier"] ||
                [propertyName isEqualToString:@"serializerQueue"]) { continue; }
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
        _serializerQueueIdentifier = [[NSUUID alloc] init];
        _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);

        if (propertyCount > 0) {
            free(properties);
        }
        
    }
    

    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (aCoder == nil) {
        return;
    }
    
    uint propertyCount;
    objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
        if ([propertyName isEqualToString:@"serializerQueueIdentifier"] ||
            [propertyName isEqualToString:@"serializerQueue"]) { continue; }
        [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    if (propertyCount > 0) {
        free(properties);
    }

}

#pragma mark - Binding Management

- (BOOL)bind:(NSError * __autoreleasing _Nullable * _Nullable)error {
    __block BOOL result = NO;
    
    dispatch_sync(_serializerQueue, ^{
        if ((result = [super bind:error]) == NO) { return; }
        
        if ([self.observer respondsToSelector:_bindingInvocation.bindingSelector] && [self.observer respondsToSelector:_unbindingInvocation.bindingSelector]) {
            NSInvocation *invocation = _bindingInvocation.bindingObjectValue;
            if (invocation == nil) { return; }
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation invoke];
            });
        } else { return; }
        
    });
    
    return result;
}

- (BOOL)unbind:(NSError *__autoreleasing  _Nullable *)error {
    __block BOOL result = NO;
    
    dispatch_sync(_serializerQueue, ^{
        if ((result = [super unbind:error]) == NO) { return; }

        if ([self.observer respondsToSelector:_bindingInvocation.bindingSelector] && [self.observer respondsToSelector:_unbindingInvocation.bindingSelector]) {
            NSInvocation *invocation = _unbindingInvocation.bindingObjectValue;
            if (invocation == nil) { return; }
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation invoke];
            });
        } else { return; }
        
    });
    
    return result;

}

- (void)performBindingObjectAction {
    dispatch_sync(_serializerQueue, ^{
        dispatch_set_context(self.syncQueue, NULL);
        for (NSInvocation *invocation in self.bindingObjectValue) {
            [invocation invoke];
        }
        dispatch_set_context(self.syncQueue, NULL);
    });
}

- (void)performBindingObjectAction:(id _Nullable)sender {
    dispatch_sync(_serializerQueue, ^{
        NSMutableDictionary *contextDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        if (sender != nil) { [contextDictionary setObject:sender forKey:RNDSenderArgument]; }
        dispatch_set_context(self.syncQueue, (__bridge void * _Nullable)(contextDictionary));
        for (NSInvocation *invocation in self.bindingObjectValue) {
            [invocation invoke];
        }
        dispatch_set_context(self.syncQueue, NULL);
    });
}

- (void)performBindingObjectAction:(id _Nullable)sender forEvent:(id _Nullable)event {
    dispatch_sync(_serializerQueue, ^{
        NSMutableDictionary *contextDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        if (sender != nil) { [contextDictionary setObject:sender forKey:RNDSenderArgument]; }
        if (event != nil) { [contextDictionary setObject:event forKey:RNDEventArgument]; }
        dispatch_set_context(self.syncQueue, (__bridge void * _Nullable)(contextDictionary));
        for (NSInvocation *invocation in self.bindingObjectValue) {
            [invocation invoke];
        }
        dispatch_set_context(self.syncQueue, NULL);

    });
}

- (void)performBindingObjectAction:(id _Nullable)sender forEvent:(id _Nullable)event withContext:(id _Nullable)context {
    dispatch_sync(_serializerQueue, ^{
        NSMutableDictionary *contextDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        if (sender != nil) { [contextDictionary setObject:sender forKey:RNDSenderArgument]; }
        if (event != nil) { [contextDictionary setObject:event forKey:RNDEventArgument]; }
        if (context != nil) { [contextDictionary setObject:context forKey:RNDContextArgument]; }
        dispatch_set_context(self.syncQueue, (__bridge void * _Nullable)(contextDictionary));
        for (NSInvocation *invocation in self.bindingObjectValue) {
            [invocation invoke];
        }
        dispatch_set_context(self.syncQueue, NULL);

    });
}

@end
