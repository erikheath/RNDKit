//
//  RNDBindingAdaptor.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindingAdaptor.h"
#import "RNDSimpleValueBinder.h"
#import "RNDMultiValueBinder.h"
#import "RNDMultiValuePatternBinder.h"
#import "RNDMultiValueArgumentBinder.h"
#import "RNDMultiValuePredicateBinder.h"

@interface RNDBindingAdaptor()

@property (weak, readwrite, nullable) id observer;
@property (strong, readonly, nonnull) NSMutableDictionary<RNDBindingName, RNDBinder *> *binderDictionary;
@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;

@end

@implementation RNDBindingAdaptor

#pragma mark - Properties

@synthesize binderDictionary = _binderDictionary;
@synthesize syncQueue = _syncQueue;
@synthesize identifier = _identifier;
@synthesize exposedBindings = _exposedBindings; // TODO: This should come from the config file.

- (NSDictionary<RNDBindingName, RNDBinder *> *)binders {
    return [NSDictionary dictionaryWithDictionary:self.binderDictionary];
}

- (NSMutableDictionary<RNDBindingName, RNDBinder *> *)binderDictionary {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _binderDictionary = [[NSMutableDictionary alloc] init];
    });
    return _binderDictionary;
}

#pragma mark - Object Lifecycle

+ (instancetype _Nonnull)adaptorForObject:(id)observer identifier:(NSString * _Nonnull)identifier{
    return [[RNDBindingAdaptor alloc] initWithObject:observer identifier:identifier];
}

- (instancetype _Nonnull)initWithObject:(id)observer identifier:(NSString * _Nonnull)identifier {
    if ((self = [super init]) == nil) {
        // This should never happen.
    }
    _identifier = identifier;
    _syncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return self;
}

#pragma mark - Binding Management

- (BOOL)addBinding:(RNDBindingName)bindingName forObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary<RNDBindingOption,id> *)options error:(NSError *__autoreleasing  _Nullable *)error {
   
    __block RNDBinder *binder;
    __block RNDBindingInfo *bindingInfo = [RNDBindingInfo bindingInfoForBindingName:bindingName];
    __block BOOL result = YES;
    __block NSError *internalError = nil;
    
    if ([self.exposedBindings containsObject:bindingName] == NO) {
        // Set the error and return NO;
        result = NO;
    }
    
    dispatch_barrier_sync(_syncQueue, ^{
        
        // Determine the binding type
        if (result) {
            if ([bindingInfo.bindingType isEqualToString:RNDBindingTypeSimpleValue] || [bindingInfo.bindingType isEqualToString:RNDBindingTypeSimpleValueReadOnly]) {
                binder = self.binders[bindingName] != nil ? self.binders[bindingName] : [[RNDSimpleValueBinder alloc] initWithName:bindingName error:&internalError];
                if (internalError != nil) {
                    // TODO: Set the error condition.
                    result = NO;
                    return;
                }
                result = [binder addBindingForObject:observable withKeyPath:keyPath options:options error:&internalError];
                
            } else if ([bindingInfo.bindingType isEqualToString:RNDBindingTypeMultiValueOR] || [bindingInfo.bindingType isEqualToString:RNDBindingTypeMultiValueAND]) {
                binder = self.binders[bindingName] != nil ? self.binders[bindingName] : [[RNDMultiValueBinder alloc] initWithName:bindingName error:&internalError];
                if (internalError != nil) {
                    // TODO: Set the error condition.
                    result = NO;
                    return;
                }
                result = [binder addBindingForObject:observable withKeyPath:keyPath options:options error:&internalError];
                
            } else if ([bindingInfo.bindingType isEqualToString:RNDBindingTypeMultiValueArgument]) {
                binder = self.binders[bindingName] != nil ? self.binders[bindingName] : [[RNDMultiValueArgumentBinder alloc] initWithName:bindingName error:&internalError];
                if (internalError != nil) {
                    // TODO: Set the error condition.
                    result = NO;
                    return;
                }
                result = [binder addBindingForObject:observable withKeyPath:keyPath options:options error:&internalError];
                
            } else if ([bindingInfo.bindingType isEqualToString:RNDBindingTypeMultiValuePredicate]) {
                binder = self.binders[bindingName] != nil ? self.binders[bindingName] : [[RNDMultiValuePredicateBinder alloc] initWithName:bindingName error:&internalError];
                if (internalError != nil) {
                    // TODO: Set the error condition.
                    result = NO;
                    return;
                }
                result = [binder addBindingForObject:observable withKeyPath:keyPath options:options error:&internalError];
            } else if ([bindingInfo.bindingType isEqualToString:RNDBindingTypeMultiValueWithPattern]) {
                binder = self.binders[bindingName] != nil ? self.binders[bindingName] : [[RNDMultiValuePatternBinder alloc] initWithName:bindingName error:&internalError];
                if (internalError != nil) {
                    // TODO: Set the error condition.
                    result = NO;
                    return;
                }
                result = [binder addBindingForObject:observable withKeyPath:keyPath options:options error:&internalError];
            }
        }
    });

    if (error != NULL) {
        *error = internalError;
    }
    return result;
}

- (BOOL)removeBinding:(RNDBindingName)bindingName error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __block BOOL result = YES;
    __block NSError *internalError = nil;
    
    dispatch_barrier_sync(_syncQueue, ^{
        RNDBinder *binder;
        if ((binder = self.binders[bindingName]) == nil) {
            // TODOD: Set the error condition.
            result = NO;
        }
        
        result = [binder unbind:&internalError];
    });
    
    if (error != NULL) {
        *error = internalError;
    }
    return result;
}

- (BOOL)connectAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __block BOOL result = YES;
    __block NSError *internalError = nil;

    dispatch_barrier_sync(_syncQueue, ^{
        NSDictionary *binderDictionary = self.binders;
        
        if (binderDictionary.count < 1) {
            // Set the error condition
            result = NO;
            return;
        }
        
        for (RNDBinder *binder in binderDictionary.allValues) {
            if ((result = [binder bind:&internalError]) == NO) {
                // TODO: Set the error condition.
                return;
            }
        }
    });
    
    if (error != NULL) {
        *error = internalError;
    }
    return result;

}

- (BOOL)removeAllBindings:(NSError *__autoreleasing  _Nullable *)error {
    __block BOOL result = YES;
    __block NSError *internalError = nil;

    dispatch_barrier_sync(_syncQueue, ^{
        NSDictionary *binderDictionary = self.binders;
        
        if (binderDictionary.count < 1) {
            // Set the error condition
            result = NO;
            return;
        }
        
        for (RNDBinder *binder in binderDictionary.allValues) {
            if ((result = [binder unbind:&internalError]) == NO) {
                // TODO: Set the error condition.
                return;
            }
        }
        [_binderDictionary removeAllObjects];

    });
    
    if (error != NULL) {
        *error = internalError;
    }
    return result;

}

@end

