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
#import "../NSObject+RNDObjectBinding.h"

@interface RNDMultiValueArgumentBinder ()

@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;
@property (strong, nullable, readonly) NSValueTransformer *valueTransformer;

@end

@implementation RNDMultiValueArgumentBinder

#pragma mark - Properties
@synthesize targetArray = _targetArray;
@synthesize argumentsArray = _argumentsArray;
@synthesize valueTransformer = _valueTransformer;
@synthesize controlEventMask = _controlEventMask;
@synthesize serializerQueue = _serializerQueue;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            objectValue = nil;
        }
        
        NSMutableDictionary *substitutions = [NSMutableDictionary dictionaryWithCapacity:_argumentsArray.count];
        for (RNDBinding *binding in _argumentsArray) {
            [substitutions setObject:binding.bindingObjectValue forKey:binding.argumentName];
        }
        
        for (RNDInvocationBinding *binding in _targetArray) {
            if ([binding evaluteBindingWithSubstitutionVariables:substitutions] == NO) { continue; }
            objectValue = [binding bindingObjectValueForBindingTargetWithSubstitutionVariables:substitutions];
            break;
        }
    });
    
    return objectValue == nil ? [NSNull null] : objectValue;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) == nil) {
        return nil;
    }

    _targetArray = [aDecoder decodeObjectForKey:@"targetArray"];
    _argumentsArray = [aDecoder decodeObjectForKey:@"argumentsArray"];
    NSNumber *maskNumber = [aDecoder decodeObjectForKey:@"controlEventMask"];
    if (maskNumber != nil) {
        _controlEventMask = [maskNumber unsignedIntegerValue];
    } else {
        _controlEventMask = 0;
    }
    
    _serializerQueueIdentifier = [[NSUUID alloc] init];
    _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);
    _valueTransformer = self.valueTransformerName != nil ? [NSValueTransformer valueTransformerForName:self.valueTransformerName] : nil;
    
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_argumentsArray forKey:@"argumentsArray"];
    [aCoder encodeObject:_targetArray forKey:@"targetArray"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:_controlEventMask] forKey:@"controlEventMask"];
}

#pragma mark - Binding Management

- (BOOL)bind:(NSError * __autoreleasing _Nullable * _Nullable)error {
    __block BOOL result = NO;
    
    dispatch_sync(_serializerQueue, ^{
        if ((result = [super bind:error]) == NO) { return; }
        SEL controlActionSelector = NSSelectorFromString(@"addTarget:action:forControlEvents:");
        if (controlActionSelector != NULL && _controlEventMask != 0 && [self.observer respondsToSelector:controlActionSelector]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSObject methodSignatureForSelector:controlActionSelector]];
            if (invocation == nil) { return; }
            [invocation retainArguments];
            [invocation setTarget:self.observer];
            [invocation setSelector:controlActionSelector];
            id object = self;
            [invocation setArgument:&object atIndex:2];
            SEL bindingSelector = @selector(performBindingObjectAction);
            [invocation setArgument:&bindingSelector atIndex:3];
            [invocation setArgument:&_controlEventMask atIndex:4];
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
        SEL controlActionSelector = NSSelectorFromString(@"removeTarget:action:forControlEvents:");
        if (controlActionSelector != NULL && _controlEventMask != 0 && [self.observer respondsToSelector:controlActionSelector]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSObject methodSignatureForSelector:controlActionSelector]];
            if (invocation == nil) { return; }
            [invocation retainArguments];
            [invocation setTarget:self.observer];
            [invocation setSelector:controlActionSelector];
            id object = self;
            [invocation setArgument:&object atIndex:2];
            SEL bindingSelector = @selector(performBindingObjectAction);
            [invocation setArgument:&bindingSelector atIndex:3];
            [invocation setArgument:&_controlEventMask atIndex:4];
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation invoke];
            });
        } else { return; }
        
    });
    
    return result;

}

-(void)performBindingObjectAction {
    NSInvocation *invocation = self.bindingObjectValue;
    if ([invocation isEqual:[NSNull null]]) {
        return;
    }
    [invocation invoke];
}

@end
