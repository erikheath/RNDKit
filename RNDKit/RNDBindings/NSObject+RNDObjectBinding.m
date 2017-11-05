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
#import "RNDBindingInfo.h"
#import <objc/runtime.h>

@implementation NSObject (RNDObjectBinding)

#pragma mark - Properties
- (NSDictionary<RNDBinderName, RNDBinder *> *)binders {
    return [NSDictionary dictionaryWithDictionary:self.bindingDictionary];
}

- (NSMutableDictionary<RNDBinderName, RNDBinder *> *)bindingDictionary {
    if (objc_getAssociatedObject(self, @selector(binders)) == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            objc_setAssociatedObject(self, @selector(binders), [[NSMutableDictionary alloc] init], OBJC_ASSOCIATION_RETAIN);
        });
    }
    return objc_getAssociatedObject(self, @selector(bindingDictionary));
}

- (NSString *)bindingIdentifier {
    return objc_getAssociatedObject(self, @selector(bindingIdentifier));
}

- (void)setBindingIdentifier:(NSString *)bindingIdentifier {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, @selector(bindingIdentifier), bindingIdentifier, OBJC_ASSOCIATION_RETAIN);
    });
}

- (dispatch_queue_t)syncQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objc_setAssociatedObject(self, @selector(syncQueue), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), OBJC_ASSOCIATION_RETAIN);
    });
    return objc_getAssociatedObject(self, @selector(syncQueue));
}

- (NSArray *)bindingDestinations {
    return objc_getAssociatedObject(self, @selector(bindingDestinations));
}

- (void)setBindingDestinations:(NSArray *)bindingDestinations {
    objc_setAssociatedObject(self, @selector(bindingDestinations), bindingDestinations, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - Object Lifecycle

- (instancetype _Nullable)initWithCoder:(NSCoder *)aDecoder {
    
    
    if ((self = [self init]) != nil) {
        self.bindingIdentifier = [aDecoder decodeObjectForKey:@"bindingIdentifier"];
        self.bindingDestinations = [aDecoder decodeObjectForKey:@"bindingDestinations"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder setValue:self.bindingIdentifier forKey:@"bindingIdentifier"];
    [aCoder setValue:self.bindingDestinations forKey:@"bindingDestinations"];
}


// Assume that this has been swizzled in for the default no-op implementation.
- (void)awakeFromNib {
    NSError *internalError = nil;
    if ([self loadAllBindings:&internalError] && [self connectAllBindings:&internalError] != YES) {
        // TODO: Report the error.
    }
    return;
}

#pragma mark - Binding Management

- (BOOL)loadAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __block BOOL result = YES;
    __block NSError *internalError = nil;

    dispatch_barrier_sync(self.syncQueue, ^{
        [self.bindingDictionary addEntriesFromDictionary:[RNDBindingInfo bindersForBindingIdentifier:self.bindingIdentifier error:&internalError]];
        for (RNDBinder *binder in self.bindingDictionary) {
            binder.observer = self;
        }
    });
    
    if (error != NULL) {
        *error = internalError;
    }
    return result;
}

- (BOOL)connectAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error {
    __block BOOL result = YES;
    __block NSError *internalError = nil;
    
    dispatch_barrier_sync(self.syncQueue, ^{
        NSDictionary *binderDictionary = self.bindingDictionary;
        
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
    
    dispatch_barrier_sync(self.syncQueue, ^{
        NSDictionary *binderDictionary = self.bindingDictionary;
        
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


#pragma mark - RNDEditor Conformance

- (BOOL)commitEditing {
    return NO;
}

- (void)discardEditing {
    return;
}

- (BOOL)commitEditingAndReturnError:(NSError *__autoreleasing  _Nullable *)error {
    return NO;
}

- (void)commitEditingWithDelegate:(id<RNDEditorDelegate>)delegate
                didCommitSelector:(SEL)didCommitSelector
                      contextInfo:(void *)contextInfo {
    return;
}


@end
