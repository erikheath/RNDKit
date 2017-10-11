//
//  RNDLabel.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/10/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDLabel.h"



@implementation RNDLabel

@synthesize exposedBindings;


- (BOOL)commitEditing {
    return YES;
}

- (BOOL)commitEditingAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return YES;
}

- (void)commitEditingWithDelegate:(nullable id<RNDEditorDelegate>)delegate didCommitSelector:(nullable SEL)didCommitSelector contextInfo:(nullable void *)contextInfo {
    <#code#>
}

- (void)discardEditing {
    <#code#>
}

- (void)bind:(nonnull RNDBindingName)binding toObject:(nonnull id)observable withKeyPath:(nonnull NSString *)keyPath options:(nullable NSDictionary<RNDBindingOption,id> *)options {
    
    // Add to dictionary
    
    
    // Set up options
    
    // Add observer
    [observable addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:(__bridge void * _Nullable)(binding)];
}

+ (void)exposeBinding:(nonnull RNDBindingName)binding {
    <#code#>
}

- (nullable NSDictionary<RNDBindingInfoKey,id> *)infoForBinding:(nonnull RNDBindingName)binding {
    return nil;
}

- (nonnull NSArray<NSAttributeDescription *> *)optionDescriptionsForBinding:(nonnull RNDBindingName)binding {
    return nil;
}

- (void)unbind:(nonnull RNDBindingName)binding {
    <#code#>
}

- (nullable Class)valueClassForBinding:(nonnull RNDBindingName)binding {
    return nil;
}

+ (nullable id)defaultPlaceholderForMarker:(nullable id)marker withBinding:(nonnull RNDBindingName)binding {
    return nil;
}

+ (void)setDefaultPlaceholder:(nullable id)placeholder forMarker:(nullable id)marker withBinding:(nonnull RNDBindingName)binding {
    <#code#>
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    <#code#>
}

@end
