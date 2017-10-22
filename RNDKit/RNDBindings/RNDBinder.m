//
//  RNDBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinder.h"
#import "RNDBindingAdaptor.h"


@implementation RNDBinder

#pragma mark - Properties

@synthesize name = _name;

- (RNDBindingInfo *)bindingInfo {
    return [RNDBindingInfo bindingInfoForBindingName:_name];
}

- (NSArray<RNDBinding *> * _Nonnull)bindings {
    return @[];
}

#pragma mark - Object Lifecycle

- (instancetype _Nullable)init {
    return [self initWithName:@"" error:nil];
}

- (instancetype)initWithName:(RNDBindingName _Nonnull)bindingName error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    
    if ([[RNDBindingInfo RNDBindingNames] containsObject:bindingName] != YES) {
        // TODO: Set error condition.
        return nil;
    }
    
    if ((self = [super init]) == nil) {
        // TODO: Set error condition.
        return nil;
    }
    
    _name = bindingName;
    return self;
}

#pragma mark - Binding Management

- (BOOL)addBindingForObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary<RNDBindingOption,id> *)options error:(NSError * _Nullable __autoreleasing *)error {
    // TODO: Set error condition. Method must be overridden.
    return NO;
}

- (BOOL)bind:(NSError *__autoreleasing  _Nullable *)error {
    // TODO: Set error condition. Method must be overridden.
    return NO;
}

- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    // TODO: Set error condition. Method must be overridden.
    return NO;
}

@end


