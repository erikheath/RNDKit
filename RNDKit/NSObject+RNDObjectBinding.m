//
//  NSObject+RNDObjectBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/21/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "NSObject+RNDObjectBinding.h"
#import <objc/runtime.h>

// This category is dynamically generated and provides the shims to access the binding adaptor or to override any of the calls by the observing class to the binding adaptor.

@implementation NSObject (RNDObjectBinding)

- (RNDBindingAdaptor *)adaptor {
    return objc_getAssociatedObject(self, @selector(initializeBindings:));
}

- (void)initializeBindings:(NSString * _Nonnull)identifier {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RNDBindingAdaptor *adaptor = [RNDBindingAdaptor adaptorForObject:self
                                                              identifier:identifier];
        if (objc_getAssociatedObject(self, @selector(initializeBindings:)) == nil) {
            objc_setAssociatedObject(self, @selector(initializeBindings:), adaptor, OBJC_ASSOCIATION_RETAIN);
        }
    });
}

// Use these methods in subclasses to provide additional or alternate implementations.
#pragma mark - RNDEditor

- (BOOL)commitEditing {
    return [self.adaptor commitEditing];
}

- (void)discardEditing {
    return [self.adaptor discardEditing];
}

- (BOOL)commitEditingAndReturnError:(NSError *__autoreleasing  _Nullable *)error {
    return [self.adaptor commitEditingAndReturnError:error];
}

- (void)commitEditingWithDelegate:(id<RNDEditorDelegate>)delegate
                didCommitSelector:(SEL)didCommitSelector
                      contextInfo:(void *)contextInfo {
    return [self.adaptor commitEditingWithDelegate:delegate
                                 didCommitSelector:didCommitSelector
                                       contextInfo:contextInfo];
}

@end
