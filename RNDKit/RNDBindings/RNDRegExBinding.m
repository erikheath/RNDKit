//
//  RNDRegExBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDRegExBinding.h"

@implementation RNDRegExBinding

#pragma mark - Properties
@synthesize regExTemplate = _regExTemplate;
@synthesize replacementTemplate = _replacementTemplate;
@synthesize evaluates = _evaluates;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.serializerQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        NSMutableString *replacableObjectValue = [NSMutableString stringWithString:_regExTemplate];
        
        for (RNDBinding *binding in self.bindingArguments) {
            [replacableObjectValue replaceOccurrencesOfString:binding.argumentName
                                                   withString:binding.bindingObjectValue
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
        if (_evaluates == NO) {
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
    return [self initWithCoder:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _regExTemplate = [aDecoder decodeObjectForKey:@"expressionTemplate"];
        _replacementTemplate = [aDecoder decodeObjectForKey:@"replacementTemplate"];
        _evaluates = [aDecoder decodeBoolForKey:@"evaluates"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_regExTemplate forKey:@"expressionTemplate"];
    [aCoder encodeObject:_replacementTemplate forKey:@"replacementTemplate"];
    [aCoder encodeBool:_evaluates forKey:@"evaluates"];
}

#pragma mark - Binding Management

@end
