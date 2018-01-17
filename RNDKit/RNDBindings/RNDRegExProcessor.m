//
//  RNDRegExProcessor.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDRegExProcessor.h"
#import "RNDPredicateProcessor.h"

@implementation RNDRegExProcessor

#pragma mark - Properties
@synthesize regExTemplate = _regExTemplate;
@synthesize replacementTemplate = _replacementTemplate;

- (void)setRegExTemplate:(NSString * _Nullable)regExTemplate {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _regExTemplate = regExTemplate;
    });
}

- (NSString * _Nullable)regExTemplate {
    id __block localObject = nil;
    dispatch_sync(self.coordinator, ^{
        localObject = _regExTemplate;
    });
    return localObject;
}

- (void)setReplacementTemplate:(NSString * _Nullable)replacementTemplate {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _replacementTemplate = replacementTemplate;
    });
}

- (NSString * _Nullable)replacementTemplate {
    id __block localObject = nil;
    dispatch_sync(self.coordinator, ^{
        localObject = _regExTemplate;
    });
    return localObject;
}

- (id _Nullable)bindingValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.coordinator, ^{
        
        if (self.isBound == NO) {
            objectValue = nil;
            return;
        }
        
        if (self.processorCondition != nil && ((NSNumber *)self.processorCondition.bindingValue).boolValue == NO ) {
            objectValue = nil;
            return;
        }

        NSMutableString *replacableObjectValue = [NSMutableString stringWithString:_regExTemplate];
        
        for (RNDBindingProcessor *binding in self.boundProcessorArguments) {
            [replacableObjectValue replaceOccurrencesOfString:binding.argumentName
                                                   withString:binding.bindingValue
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
            for (RNDBindingProcessor *binding in self.boundProcessorArguments) {
                [replacementTemplateValue replaceOccurrencesOfString:binding.argumentName
                                                          withString:binding.bindingValue
                                                             options:0
                                                               range:NSMakeRange(0, _replacementTemplate.length)];
            }
            
        }
        
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:replacableObjectValue options:0 error:nil];
        if (self.processorOutputType == RNDRawValueOutputType) {
            objectValue = @[expression, replacementTemplateValue];
            return;
            // TODO: Error Handling
        } else {
            objectValue = [expression stringByReplacingMatchesInString:self.observedObjectBindingValue options:0 range:NSMakeRange(0, ((NSString *)self.observedObjectBindingValue).length) withTemplate:replacementTemplateValue];
            
            if ([objectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                objectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder.bindingValue : objectValue;
                return;
            }
            
            if ([objectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                objectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder.bindingValue : objectValue;
                return;
            }
            
            if ([objectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                objectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder.bindingValue : objectValue;
                return;
            }
            
            if ([objectValue isEqual: RNDBindingNullValueMarker] == YES) {
                objectValue = self.nullPlaceholder != nil ? self.nullPlaceholder.bindingValue : objectValue;
                return;
            }
            
            if (objectValue == nil) {
                objectValue = self.nilPlaceholder != nil ? self.nilPlaceholder.bindingValue : objectValue;
                return;
            }
            
            objectValue = self.valueTransformer != nil ? [self.valueTransformer transformedValue:objectValue] : objectValue;
        }

    });
    
    return objectValue;
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
