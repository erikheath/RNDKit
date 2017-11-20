//
//  RNDPatternedBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDPatternedBinding.h"

@implementation RNDPatternedBinding

#pragma mark - Properties
@synthesize patternTemplate = _patternTemplate;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.serializerQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        NSMutableString *replacableObjectValue = [NSMutableString stringWithString:_patternTemplate];
        
        for (RNDBinding *binding in self.bindingArguments) {
            
            id rawObjectValue = binding.bindingObjectValue;
            
            if ([rawObjectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                objectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder : rawObjectValue;
                return;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                objectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder : rawObjectValue;
                return;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                objectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder : rawObjectValue;
                return;
            }
            
            if (rawObjectValue == nil) {
                objectValue = self.nullPlaceholder != nil ? self.nullPlaceholder : objectValue;
                return;
            }
            
            [replacableObjectValue replaceOccurrencesOfString:binding.argumentName
                                                   withString:binding.bindingObjectValue
                                                      options:0
                                                        range:NSMakeRange(0, replacableObjectValue.length)];
        }
        
        
        
        objectValue = self.valueTransformer != nil ? [self.valueTransformer transformedValue:replacableObjectValue] : replacableObjectValue;;

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
        _patternTemplate = [aDecoder decodeObjectForKey:@"patternTemplate"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_patternTemplate forKey:@"patternTemplate"];
}

#pragma mark - Binding Management

@end
