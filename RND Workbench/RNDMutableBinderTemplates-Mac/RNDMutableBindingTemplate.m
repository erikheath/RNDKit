//
//  RNDBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMutableBindingTemplate.h"
#import <objc/runtime.h>
#import "../RNDBinder.h"
#import "../RNDBinding.h"

@implementation RNDMutableBindingTemplate

#pragma mark - Properties

@synthesize observedObjectBindingIdentifier = _observedObjectBindingIdentifier;
@synthesize observedKeyPath = _observedKeyPath;
@synthesize binderTemplate = _binderTemplate;
@synthesize nullPlaceholder = _nullPlaceholder;
@synthesize multipleSelectionPlaceholder = _multipleSelectionPlaceholder;
@synthesize noSelectionPlaceholder = _noSelectionPlaceholder;
@synthesize notApplicablePlaceholder = _notApplicablePlaceholder;
@synthesize filterPredicate = _filterPredicate;
@synthesize argumentName = _argumentName;
@synthesize valueTransformerName = _valueTransformerName;
@synthesize monitorsObservedObject = _monitorsObservedObject;

#pragma mark - Object Lifecycle

+ (instancetype _Nullable)bindingForBinderTemplate:(RNDMutableBinderTemplate * _Nonnull)binderTemplate
       withObservedObjectBindingIdentifier:(NSString * _Nonnull )bindingIdentifier
                                   keyPath:(NSString *_Nonnull)keyPath
                                   options:(NSDictionary<RNDBindingOption, id> * _Nullable)options
                                     error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return [[RNDMutableBindingTemplate alloc] initWithBinderTemplate:binderTemplate
                                     observedObjectBindingIdentifier:bindingIdentifier
                                                             keyPath:keyPath
                                                             options:options
                                                               error:error];
}

- (instancetype)init {
    return nil;
}

- (instancetype _Nullable )initWithBinderTemplate:(RNDMutableBinderTemplate * _Nonnull)binderTemplate
                  observedObjectBindingIdentifier:(NSString * _Nonnull )bindingIdentifier
                                          keyPath:(NSString *_Nonnull)keyPath
                                          options:(NSDictionary<RNDBindingOption, id> * _Nullable)options
                                            error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    
    NSError *internalError = nil;
    
    if ((self = [super init]) == nil) {
        // TODO: Set the error and return
        return self;
    }
    
    _binderTemplate = binderTemplate;
    _observedObjectBindingIdentifier = bindingIdentifier;
    _observedKeyPath = keyPath;
    
    NSArray *keys = [options allKeys];
    for (RNDBindingOption key in keys) {
        [self setValue:options[key] forKey:key];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init]) != nil) {
        
        uint propertyCount;
        objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
        if (propertyCount > 0) {
            free(properties);
        }

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    uint propertyCount;
    objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
        [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }

    if (propertyCount > 0) {
        free(properties);
    }
    
}


@end

