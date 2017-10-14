//
//  UIView+RNDBindings.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/11/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "UIView+RNDBindings.h"
#import <objc/runtime.h>

@implementation UIView (RNDBindings)

- (void)bind:(nonnull RNDBindingName)binding toObject:(nonnull id)observable withKeyPath:(nonnull NSString *)keyPath options:(nullable NSDictionary<RNDBindingOption,id> *)options {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (objc_getAssociatedObject(self, @selector(exposedBindings)) == nil) {
            NSMutableDictionary *bindingsDictionary = [[NSMutableDictionary alloc] init];
            objc_setAssociatedObject(self, @selector(exposedBindings), bindingsDictionary, OBJC_ASSOCIATION_RETAIN);
        }
    });
}

+ (void)exposeBinding:(nonnull RNDBindingName)binding {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self class] initializeBindings];
    });
    NSMutableSet *bindingSet = objc_getAssociatedObject([self class], @selector(exposedBindings));
    [bindingSet addObject:binding];
}

+ (void)initializeBindings {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (objc_getAssociatedObject(self, @selector(exposedBindings)) == nil) {
            // Add the bindings for UIView. this should be done once in a thread safe manner.
            NSMutableSet<RNDBindingName> *bindingSet = [[NSMutableSet alloc] init];
            [bindingSet addObjectsFromArray:[self defaultBindings]];
            objc_setAssociatedObject(self, @selector(exposedBindings), bindingSet, OBJC_ASSOCIATION_RETAIN);
        }
        if ([[self superclass] respondsToSelector:@selector(initializeBindings)] == YES) {
            [[self superclass] initializeBindings];
        }
    });
}

+ (NSArray<RNDBindingName> *)defaultBindings {
    return @[RNDHiddenBinding];
}

+ (NSArray<RNDBindingName>*)exposedBindings {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initializeBindings];
    });
    return objc_getAssociatedObject([self class], @selector(exposedBindings));
}

+ (NSArray *)allExposedBindings {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initializeBindings];
    });
    
    NSMutableArray *allBindings = [NSMutableArray arrayWithArray:self.exposedBindings];
    if ([[self superclass] respondsToSelector:@selector(allExposedBindings)]) {
        [allBindings addObjectsFromArray:[[self superclass] allExposedBindings]];
    }
    
    return allBindings;
}

/* Returns a dictionary with information about a binding or nil if the binding is not bound (this is mostly for use by subclasses which want to analyze the existing bindings of an object) - the dictionary contains three key/value pairs: NSObservedObjectKey: object bound, NSObservedKeyPathKey: key path bound, NSOptionsKey: dictionary with the options and their values for the bindings.
 */

- (nullable NSDictionary<RNDBindingInfoKey,id> *)infoForBinding:(nonnull RNDBindingName)binding {
    return objc_getAssociatedObject(self, @selector(exposedBindings))[binding];
}

/* Returns an array of NSAttributeDescriptions that describe the options for aBinding. The descriptions are used by Interface Builder to build the options editor UI of the bindings inspector. Each binding may have multiple options. The options and attribute descriptions have 3 properties in common:
 
 - The option "name" is derived from the attribute description name.
 
 - The type of UI built for the option is based on the attribute type.
 
 - The default value shown in the options editor comes from the attribute description's defaultValue.*/

- (nonnull NSArray<NSAttributeDescription *> *)optionDescriptionsForBinding:(nonnull RNDBindingName)bindingName {
    
    return [RNDBinding bindingOptionsInfoForBindingName:bindingName];
}

- (void)unbind:(nonnull RNDBindingName)binding {
    
}

- (nullable Class)valueClassForBinding:(nonnull RNDBindingName)bindingName {
    return nil;

}

+ (nullable id)defaultPlaceholderForMarker:(nullable id)marker withBinding:(nonnull RNDBindingName)bindingName {
    return nil;

}

+ (void)setDefaultPlaceholder:(nullable id)placeholder forMarker:(nullable id)marker withBinding:(nonnull RNDBindingName)bindingName {
    
}

- (BOOL)commitEditing {
    return NO;
}

- (BOOL)commitEditingAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return NO;
}

- (void)commitEditingWithDelegate:(nullable id<RNDEditorDelegate>)delegate didCommitSelector:(nullable SEL)didCommitSelector contextInfo:(nullable void *)contextInfo {
    
}

- (void)discardEditing {
    
}

- (void)objectDidBeginEditing:(nonnull id)editor {
    
}

- (void)objectDidEndEditing:(nonnull id)editor {
    
}

- (void)editor:(nonnull id<RNDEditor>)editor didCommit:(BOOL)didCommit contextInfo:(nonnull void *)contextInfo {
    
}

@end
