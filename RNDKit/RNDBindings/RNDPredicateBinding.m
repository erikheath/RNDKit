//
//  RNDPredicateBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/9/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDPredicateBinding.h"

@implementation RNDPredicateBinding
#pragma mark - Properties
@synthesize predicateFormatString = _predicateFormatString;
@synthesize evaluates = _evaluates;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.serializerQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        NSMutableDictionary * __block argumentsDictionary = [NSMutableDictionary dictionary];

        [self.bindingArguments enumerateObjectsUsingBlock:^(RNDBinding * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RNDBinding *binding = obj;
            id argumentValue = binding.bindingObjectValue;
            [argumentsDictionary setObject:argumentValue forKey:binding.argumentName];
        }];
        
        NSPredicate *predicate = [[NSPredicate predicateWithFormat:_predicateFormatString]  predicateWithSubstitutionVariables: argumentsDictionary];
        
        if (_evaluates == NO) {
            objectValue = predicate;
            return;
            // TODO: Error Handling
        } else {
            objectValue = @([predicate evaluateWithObject:self.evaluatedObject]);
            
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
        _predicateFormatString = [aDecoder decodeObjectForKey:@"predicateFormatString"];
        _evaluates = [aDecoder decodeBoolForKey:@"evaluates"];

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (aCoder == nil) { return; }
    [aCoder encodeObject:_predicateFormatString forKey:@"predicateFormatString"];
    [aCoder encodeBool:_evaluates forKey:@"evaluates"];

}

#pragma mark - Binding Management

@end
