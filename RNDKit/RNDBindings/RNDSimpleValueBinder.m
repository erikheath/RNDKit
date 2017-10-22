//
//  RNDSimpleValueBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDSimpleValueBinder.h"

@interface RNDSimpleValueBinder()

@property (nonnull, strong, readonly) NSMutableArray<RNDBinding *> * bindingArray;
@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;
@end

@implementation RNDSimpleValueBinder

#pragma mark - Properties

@synthesize bindingArray = _bindingArray;
@synthesize syncQueue = _syncQueue;

- (BOOL)isReadOnly {
    return self.bindingInfo.bindingType == RNDBindingTypeSimpleValueReadOnly;
}

- (NSArray<RNDBinding *> *_Nonnull)bindings {
    
    __block NSArray *currentBindings;
    dispatch_sync(_syncQueue, ^{
        currentBindings = [NSArray arrayWithArray:self.bindingArray];
    });
    return currentBindings;
}

- (NSMutableArray<RNDBinding *> * _Nonnull)bindingArray {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bindingArray = [[NSMutableArray alloc] initWithCapacity:1];
    });
    return _bindingArray;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithName:(RNDBindingName)bindingName error:(NSError * _Nullable __autoreleasing *)error {
    
    if ((self = [super initWithName:bindingName error:error]) == nil) {
        return nil;
    }
    
    if (self.bindingInfo.bindingType != RNDBindingTypeSimpleValue && self.bindingInfo.bindingType != RNDBindingTypeSimpleValueReadOnly) {
        // TODO: Set the error condition.
        return nil;
    }

    _syncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    return self;
}

#pragma mark - Binding Management

- (BOOL)addBindingForObject:(id _Nonnull )observable withKeyPath:(NSString *_Nonnull)keyPath options:(NSDictionary<RNDBindingOption,id> *_Nullable)options error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    
    __block BOOL result = YES;
    dispatch_barrier_sync(_syncQueue, ^{
        
        if (result && self.bindings.count > 0) {
            // TODO: Set the error condition
            result = NO;
            return;
        }
        
        [self.bindingArray addObject:[RNDBinding bindingForBinder:self withObserved:observable keyPath:keyPath options:options]];
    });
    
    return YES;
}

- (BOOL)bind:(NSError *__autoreleasing  _Nullable *)error {
    __block BOOL result = YES;
    dispatch_barrier_sync(_syncQueue, ^{
        if (_bindingArray.count < 1) {
            // TODO: Set the error condition
            result = NO;
            return;
        }
        for (RNDBinding *binding in _bindingArray) {
            [binding bind];
        }
    });
    return result;
}

- (BOOL)unbind:(NSError *__autoreleasing  _Nullable *)error {
    __block BOOL result = YES;
    dispatch_barrier_sync(_syncQueue, ^{
        if (_bindingArray.count < 1) {
            // TODO: Set the error condition
            result = NO;
            return;
        }
        for (RNDBinding *binding in _bindingArray) {
            [binding unbind];
        }
    });
    return result;
}

@end
