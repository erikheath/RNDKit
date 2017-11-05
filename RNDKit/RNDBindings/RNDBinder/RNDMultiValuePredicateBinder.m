//
//  RNDMultiValuePredicateBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValuePredicateBinder.h"
#import "RNDBinding.h"

@interface RNDMultiValuePredicateBinder ()

@property (nonnull, strong, readonly) NSMutableArray<RNDBinding *> * bindingArray;

@end

@implementation RNDMultiValuePredicateBinder

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) == nil) {
        return nil;
    }
    
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_bindingArray forKey:@"bindingArray"];
}


#pragma mark - Binding Management

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
