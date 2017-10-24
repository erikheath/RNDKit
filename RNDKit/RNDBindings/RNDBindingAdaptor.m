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

@property (strong, readonly, nonnull) NSMutableDictionary<RNDBindingName, RNDBinder *> *binderDictionary;
@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;

@end

@implementation RNDBindingAdaptor

#pragma mark - Properties

@synthesize binderDictionary = _binderDictionary;
@synthesize syncQueue = _syncQueue;
@synthesize identifier = _identifier;

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

+ (instancetype _Nullable)adaptorForObject:(id)observer identifier:(NSString * _Nonnull)identifier{
    return [[RNDBindingAdaptor alloc] initWithObject:observer identifier:identifier];
}

- (instancetype _Nullable)initWithObject:(id)observer identifier:(NSString * _Nonnull)identifier {
    if ((self = [super init]) == nil) {
        // This should never happen.
    }
    _identifier = identifier;
    _syncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return self;
}

- (instancetype _Nullable)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init]) != nil) {
        _binderDictionary = [aDecoder decodeObjectForKey:@"binders"];
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        for (RNDBinder *binder in [_binderDictionary allValues]) {
            binder.adaptor = self;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
}

#pragma mark - Binding Management

- (BOOL)removeBinding:(RNDBindingName)bindingName error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __block BOOL result = YES;
    __block NSError *internalError = nil;
    
    dispatch_barrier_sync(_syncQueue, ^{
        RNDBinder *binder;
        if ((binder = self.binders[bindingName]) == nil) {
            // TODO: Set the error condition.
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

- (BOOL)disconnectAllBindings:(NSError *__autoreleasing  _Nullable *)error {
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
    });
    
    if (error != NULL) {
        *error = internalError;
    }
    return result;

}

@end

