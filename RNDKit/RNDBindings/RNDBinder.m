//
//  RNDBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinder.h"
#import "RNDBindingAdaptor.h"
#import <objc/runtime.h>


@implementation RNDBinder

#pragma mark - Properties

@synthesize name = _name;
@synthesize adaptor = _adaptor;

- (NSArray<RNDBinding *> * _Nonnull)bindings {
    return @[];
}

#pragma mark - Object Lifecycle

- (instancetype _Nullable)init {
    return [self initWithName:@"" error:nil];
}

- (instancetype)initWithName:(RNDBindingName _Nonnull)bindingName error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
        
    if ((self = [super init]) == nil) {
        // TODO: Set error condition.
        return nil;
    }
    
    _name = bindingName;
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init]) != nil) {
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
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


