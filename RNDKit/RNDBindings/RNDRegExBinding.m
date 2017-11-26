//
//  RNDRegExBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDRegExBinding.h"
#import "RNDPredicateBinding.h"

@implementation RNDRegExBinding

#pragma mark - Properties
@synthesize regExTemplate = _regExTemplate;
@synthesize replacementTemplate = _replacementTemplate;

- (void)setRegExTemplate:(NSString * _Nullable)regExTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _regExTemplate = regExTemplate;
    });
}

- (NSString * _Nullable)regExTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _regExTemplate;
    });
    return localObject;
}

- (void)setReplacementTemplate:(NSString * _Nullable)replacementTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _replacementTemplate = replacementTemplate;
    });
}

- (NSString * _Nullable)replacementTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _regExTemplate;
    });
    return localObject;
}

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            objectValue = nil;
            return;
        }
        
        if (((NSNumber *)self.evaluator.bindingObjectValue).boolValue == NO ) {
            objectValue = nil;
            return;
        }

        NSMutableString *replacableObjectValue = [NSMutableString stringWithString:_regExTemplate];
        
        for (RNDBinding *binding in self.bindingArguments) {
            [replacableObjectValue replaceOccurrencesOfString:binding.argumentName
                                                   withString:binding.bindingObjectValue
                                                      options:0
                                                        range:NSMakeRange(0, replacableObjectValue.length)];
        }
        
        for (NSString *runtimeKey in self.runtimeArguments) {
            [replacableObjectValue replaceOccurrencesOfString:runtimeKey
                                                   withString:self.runtimeArguments[runtimeKey]
                                                      options:0
                                                        range:NSMakeRange(0, replacableObjectValue.length)];
        }

        
        NSMutableString *replacementTemplateValue = _replacementTemplate != nil ? [NSMutableString stringWithString:_replacementTemplate] : nil;
        if (replacementTemplateValue != nil) {
            for (RNDBinding *binding in self.bindingArguments) {
                [replacementTemplateValue replaceOccurrencesOfString:binding.argumentName
                                                          withString:binding.bindingObjectValue
                                                             options:0
                                                               range:NSMakeRange(0, _replacementTemplate.length)];
            }
            
        }
        
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:replacableObjectValue options:0 error:nil];
        if (self.evaluates == NO) {
            objectValue = @[expression, replacementTemplateValue];
            return;
            // TODO: Error Handling
        } else {
            objectValue = [expression stringByReplacingMatchesInString:self.evaluatedObject options:0 range:NSMakeRange(0, ((NSString *)self.evaluatedObject).length) withTemplate:replacementTemplateValue];
            
            if ([objectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                objectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder.bindingObjectValue : objectValue;
                return;
            }
            
            if ([objectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                objectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder.bindingObjectValue : objectValue;
                return;
            }
            
            if ([objectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                objectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder.bindingObjectValue : objectValue;
                return;
            }
            
            if ([objectValue isEqual: RNDBindingNullValueMarker] == YES) {
                objectValue = self.nullPlaceholder != nil ? self.nullPlaceholder.bindingObjectValue : objectValue;
                return;
            }
            
            if (objectValue == nil) {
                objectValue = self.nilPlaceholder != nil ? self.nilPlaceholder.bindingObjectValue : objectValue;
                return;
            }
            
            objectValue = self.valueTransformer != nil ? [self.valueTransformer transformedValue:objectValue] : objectValue;
        }

    });
    
    return objectValue;
}

- (void)setBindingObjectValue:(id)bindingObjectValue {
    return;
}

#pragma mark - Object Lifecycle
- (instancetype)init {
    return [super init];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _regExTemplate = [aDecoder decodeObjectForKey:@"expressionTemplate"];
        _replacementTemplate = [aDecoder decodeObjectForKey:@"replacementTemplate"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_regExTemplate forKey:@"expressionTemplate"];
    [aCoder encodeObject:_replacementTemplate forKey:@"replacementTemplate"];
}

#pragma mark - Binding Management
-(BOOL)bindObjects:(NSError * _Nullable __autoreleasing *)error {
    if (_regExTemplate == nil) {
        return NO;
    }
    return [super bindObjects:error];
}

@end
