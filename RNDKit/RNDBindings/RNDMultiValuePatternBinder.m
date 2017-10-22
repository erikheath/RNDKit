//
//  RNDMultiValuePatternBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValuePatternBinder.h"

@interface RNDMultiValuePatternBinder ()

@property (nonnull, strong, readonly) NSMutableArray<RNDBinding *> * bindingArray;
@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;

@end

@implementation RNDMultiValuePatternBinder

#pragma mark - Properties

@synthesize bindingArray = _bindingArray;
@synthesize syncQueue = _syncQueue;

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
        _bindingArray = [[NSMutableArray alloc] init];
    });
    return _bindingArray;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithName:(RNDBindingName)bindingName error:(NSError * _Nullable __autoreleasing *)error {
    
    if ((self = [super initWithName:bindingName error:error]) == nil) {
        return nil;
    }
    
    if (self.bindingInfo.bindingType != RNDBindingTypeMultiValueWithPattern) {
        // TODO: Set the error condition
        return nil;
    }
    
    _syncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    return self;
}

#pragma mark - Binding Management

- (BOOL)addBindingForObject:(id _Nonnull )observable withKeyPath:(NSString *_Nonnull)keyPath options:(NSDictionary<RNDBindingOption,id> *_Nullable)options error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    
    __block BOOL result = YES;
    dispatch_barrier_sync(_syncQueue, ^{
        // TODO: Autogenerated runtime parameter validation
        
        if (options[RNDArgumentPositionBindingOption] == nil) {
            // TODO: Set the error condition
            result = NO;
            return;
        }
        
        if (result) {
            for (RNDBinding *binding in _bindingArray) {
                if ([binding.options[RNDArgumentPositionBindingOption] isEqualToString:options[RNDArgumentPositionBindingOption]]) {
                    // TODO: Set the error condition
                    result = NO;
                    return;
                }
            }
        }

        
        [self.bindingArray addObject:[RNDBinding bindingForBinder:self withObserved:observable keyPath:keyPath options:options]];
    });
    
    return result;
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
