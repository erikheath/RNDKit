//
//  RNDMultiValueBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValueBinder.h"

@interface RNDMultiValueBinder ()

@property (nonnull, strong, readonly) NSMutableArray<RNDBinding *> * bindingArray;
@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;

@end

@implementation RNDMultiValueBinder

#pragma mark - Properties

@synthesize bindingArray = _bindingArray;
@synthesize syncQueue = _syncQueue;

- (BOOL)isAndedValue {
    return self.bindingInfo.bindingType == RNDBindingTypeMultiValueAND;
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
        _bindingArray = [[NSMutableArray alloc] init];
    });
    return _bindingArray;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithName:(RNDBindingName)bindingName error:(NSError * _Nullable __autoreleasing *)error {
    
    if ((self = [super initWithName:bindingName error:error]) == nil) {
        return nil;
    }
    
    if (self.bindingInfo.bindingType != RNDBindingTypeMultiValueAND && self.bindingInfo.bindingType != RNDBindingTypeMultiValueOR) {
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

#pragma mark - Value Management

- (id)logicalValue:(NSError *__autoreleasing  _Nullable *)error {
    BOOL result = self.bindingInfo.bindingType == RNDBindingTypeMultiValueOR ? NO : YES;
    
    for (RNDBinding * binding in _bindingArray) {
        result = self.bindingInfo.bindingType == RNDBindingTypeMultiValueOR ? result || binding.valueAsBool : result && binding.valueAsBool;
    }
    
    return [NSNumber numberWithBool:result];
}

@end
