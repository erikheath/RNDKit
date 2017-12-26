//
//  NSObject+RNDObjectBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/21/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "NSObject+RNDObjectBinding.h"
#import "RNDBinder.h"
#import "RNDEditor.h"
#import "RNDEditorDelegate.h"
#import <objc/runtime.h>

@implementation NSObject (RNDObjectBinding)

#pragma mark - Properties

- (NSString *)bindingIdentifier {
    return objc_getAssociatedObject(self, @selector(bindingIdentifier));
}

- (void)setBindingIdentifier:(NSString *)bindingIdentifier {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, @selector(bindingIdentifier), bindingIdentifier, OBJC_ASSOCIATION_RETAIN);
    });
}

- (NSArray *)bindingDestinations {
    return objc_getAssociatedObject(self, @selector(bindingDestinations));
}

- (void)setBindingDestinations:(NSArray *)bindingDestinations {
    objc_setAssociatedObject(self, @selector(bindingDestinations), bindingDestinations, OBJC_ASSOCIATION_RETAIN);
}

- (RNDBinderSet *)bindings {
    return objc_getAssociatedObject(self, @selector(bindings));
}

- (void)setBindings:(RNDBinderSet *)bindings {
    objc_setAssociatedObject(self, @selector(bindings), bindings, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - Object Lifecycle

- (instancetype _Nullable)initWithCoder:(NSCoder *)aDecoder {
    
    
    if ((self = [self init]) != nil) {
        self.bindingIdentifier = [aDecoder decodeObjectForKey:@"bindingIdentifier"];
        self.bindingDestinations = [aDecoder decodeObjectForKey:@"bindingDestinations"];
        self.bindings = [aDecoder decodeObjectForKey:@"bindings"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.bindingIdentifier forKey:@"bindingIdentifier"];
    [aCoder encodeObject:self.bindingDestinations forKey:@"bindingDestinations"];
    [aCoder encodeObject:self.bindings forKey:@"bindings"];
}


// Assume that this has been swizzled in for the default no-op implementation.
- (void)awakeFromNib {
    NSError *internalError = nil;
    if ([self loadAllBindings:&internalError] == NO || [self connectAllBindings:&internalError] == NO) {
        // TODO: Report the error.
    }
    return;
}

#pragma mark - Binding Management

- (BOOL)loadAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __block BOOL result = YES;
    __block NSError *internalError = nil;

    
    if (error != NULL) {
        *error = internalError;
    }
    return result;
}

- (BOOL)connectAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __block BOOL result = YES;
    __block NSError *internalError = nil;
    
    
    if (error != NULL) {
        *error = internalError;
    }
    return result;
    
}

- (BOOL)disconnectAllBindings:(NSError *__autoreleasing  _Nullable *)error {
    __block BOOL result = YES;
    __block NSError *internalError = nil;
    
    
    if (error != NULL) {
        *error = internalError;
    }
    return result;
    
}

@end
