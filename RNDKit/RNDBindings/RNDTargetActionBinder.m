//
//  RNDTargetActionBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDTargetActionBinder.h"
#import "RNDInvocationProcessor.h"
#import <objc/runtime.h>

@implementation RNDTargetActionBinder

#pragma mark - Properties
@synthesize bindingInvocationProcessor = _bindingInvocationProcessor;
@synthesize unbindingInvocationProcessor = _unbindingInvocationProcessor;
@synthesize actionInvocationProcessor = _actionInvocationProcessor;

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
            if ([propertyName isEqualToString:@"bindingObject"]) { continue; }
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
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
        if ([propertyName isEqualToString:@"bindingObject"]) { continue; }
        [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    if (propertyCount > 0) {
        free(properties);
    }

}

#pragma mark - Binding Management

- (BOOL)bindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error {
    __block BOOL result = NO;

    if ((result = [super bindCoordinatedObjects:error]) == NO) { return result; }
    
    if ([self.bindingObject respondsToSelector:NSSelectorFromString(_bindingInvocationProcessor.bindingSelectorString)] && [self.bindingObject respondsToSelector:NSSelectorFromString(_unbindingInvocationProcessor.bindingSelectorString)]) {
        NSInvocation *invocation = _bindingInvocationProcessor.bindingValue;
        if (invocation == nil) {
            result = NO;
            return result;
        }
        dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
            [invocation invoke];
        });
        dispatch_async(dispatch_get_main_queue(), block);
        dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
    }
    
    return result;
}

- (BOOL)unbindCoordinatedObjects:(NSError *__autoreleasing  _Nullable *)error {
    __block BOOL result = NO;
    
    if ((result = [super unbindCoordinatedObjects:error]) == NO) { return result; }
    
    if ([self.bindingObject respondsToSelector:NSSelectorFromString(_bindingInvocationProcessor.bindingSelectorString)] && [self.bindingObject respondsToSelector:NSSelectorFromString(_unbindingInvocationProcessor.bindingSelectorString)]) {
        NSInvocation *invocation = _unbindingInvocationProcessor.bindingValue;
        if (invocation == nil) {
            result = NO;
            return result;
        }
        dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
            [invocation invoke];
        });
        dispatch_async(dispatch_get_main_queue(), block);
        dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
    }
    
    return result;

}

- (void)performBindingObjectAction {
    dispatch_barrier_async(self.coordinator, ^{
        dispatch_set_context(self.coordinator, NULL);
        for (NSInvocation *invocation in [self coordinatedBindingValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation invoke];
            });
        }
        dispatch_set_context(self.coordinator, NULL);
    });
}

- (void)performBindingObjectAction:(id _Nullable)sender {
    dispatch_barrier_sync(self.coordinator, ^{
        NSMutableDictionary *contextDictionary = [NSMutableDictionary dictionaryWithCapacity:1];
        if (sender != nil) { [contextDictionary setObject:sender forKey:RNDSenderArgument]; }
        dispatch_set_context(self.coordinator, (__bridge void * _Nullable)(contextDictionary));
        for (NSInvocation *invocation in [self coordinatedBindingValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation invoke];
            });
        }
        dispatch_set_context(self.coordinator, NULL);
    });
}

- (void)performBindingObjectAction:(id _Nullable)sender forEvent:(id _Nullable)event {
    dispatch_sync(self.coordinator, ^{
        NSMutableDictionary *contextDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        if (sender != nil) { [contextDictionary setObject:sender forKey:RNDSenderArgument]; }
        if (event != nil) { [contextDictionary setObject:event forKey:RNDEventArgument]; }
        dispatch_set_context(self.coordinator, (__bridge void * _Nullable)(contextDictionary));
        for (NSInvocation *invocation in [self coordinatedBindingValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation invoke];
            });
        }
        dispatch_set_context(self.coordinator, NULL);

    });
}

- (void)performBindingObjectAction:(id _Nullable)sender forEvent:(id _Nullable)event withContext:(id _Nullable)context {
    dispatch_sync(self.coordinator, ^{
        NSMutableDictionary *contextDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        if (sender != nil) { [contextDictionary setObject:sender forKey:RNDSenderArgument]; }
        if (event != nil) { [contextDictionary setObject:event forKey:RNDEventArgument]; }
        if (context != nil) { [contextDictionary setObject:context forKey:RNDContextArgument]; }
        dispatch_set_context(self.coordinator, (__bridge void * _Nullable)(contextDictionary));
        for (NSInvocation *invocation in [self coordinatedBindingValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation invoke];
            });
        }
        dispatch_set_context(self.coordinator, NULL);

    });
}

@end
