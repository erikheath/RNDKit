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

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    NSMutableDictionary * __block argumentsDictionary = [NSMutableDictionary dictionary];
    
    dispatch_sync(self.serializerQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        [self.bindingArguments enumerateObjectsUsingBlock:^(RNDBinding * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            RNDBinding *binding = obj;
            id argumentValue = binding.bindingObjectValue;
            
            if ([argumentValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                objectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder : RNDBindingMultipleValuesMarker;
                argumentsDictionary = nil;
                *stop = YES;
                return;
            }
            
            if ([argumentValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                objectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder : RNDBindingNoSelectionMarker;
                argumentsDictionary = nil;
                *stop = YES;
                return;
            }
            
            if ([argumentValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                objectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder : RNDBindingNotApplicableMarker;
                argumentsDictionary = nil;
                *stop = YES;
                return;
            }
            
            if (argumentValue  == nil) {
                [argumentsDictionary setObject:[NSNull null] forKey:binding.argumentName];
                return;
            }

            [argumentsDictionary setObject:argumentValue forKey:binding.argumentName];
            
        }];
        
        if (argumentsDictionary == nil) { return; }
        NSPredicate *predicate = [[NSPredicate predicateWithFormat:_predicateFormatString]  predicateWithSubstitutionVariables: argumentsDictionary];
        objectValue = predicate;
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
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (aCoder == nil) { return; }
    [aCoder encodeObject:_predicateFormatString forKey:@"predicateFormatString"];
}

#pragma mark - Binding Management

@end
