//
//  RNDMutableBindingTemplate.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMutableBinderTemplate.h"
#import <objc/runtime.h>


@implementation RNDMutableBinderTemplate

#pragma mark - Properties

@synthesize binderName = _binderName;
@synthesize observer = _observer;
@synthesize bindings = _bindings;

#pragma mark - Object Lifecycle

- (instancetype _Nullable)init {
    return nil;
}

- (instancetype)initWithBinderName:(RNDBinderName _Nonnull)binderName
                             error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init]) != nil) {
        _binderName = [aDecoder decodeObjectForKey:@"binderName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_binderName forKey:@"binderName"];
}

@end


