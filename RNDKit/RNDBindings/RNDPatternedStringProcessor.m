//
//  RNDPatternedStringProcessor.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDPatternedStringProcessor.h"
#import "RNDPredicateProcessor.h"

@implementation RNDPatternedStringProcessor

#pragma mark - Properties
@synthesize patternTemplate = _patternTemplate;

- (void)setPatternTemplate:(NSString * _Nullable)patternTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _patternTemplate = patternTemplate;
    });
}

- (NSString * _Nullable)patternTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _patternTemplate;
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
        
        if (self.observedObjectEvaluator != nil && ((NSNumber *)self.observedObjectEvaluator.bindingObjectValue).boolValue == NO ) {
            objectValue = nil;
            return;
        }

        NSMutableString *replacableObjectValue = [NSMutableString stringWithString:_patternTemplate];
        
        for (RNDBindingProcessor *binding in self.boundArguments) {
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

        
        if ([replacableObjectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
            objectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder.bindingObjectValue : replacableObjectValue;
            return;
        }
        
        if ([replacableObjectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
            objectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder.bindingObjectValue : replacableObjectValue;
            return;
        }
        
        if ([replacableObjectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
            objectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder.bindingObjectValue : replacableObjectValue;
            return;
        }
        
        if ([replacableObjectValue isEqual: RNDBindingNullValueMarker] == YES) {
            objectValue = self.nullPlaceholder != nil ? self.nullPlaceholder.bindingObjectValue : replacableObjectValue;
            return;
        }
        
        if (replacableObjectValue == nil) {
            objectValue = self.nilPlaceholder != nil ? self.nilPlaceholder.bindingObjectValue : replacableObjectValue;
            return;
        }

        
        objectValue = self.valueTransformer != nil ? [self.valueTransformer transformedValue:replacableObjectValue] : replacableObjectValue;

    });
    
    return objectValue;
}

#pragma mark - Object Lifecycle
- (instancetype)init {
    if ((self = [super init]) != nil) {
        
    }
    return self;
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
-(BOOL)bindObjects:(NSError * _Nullable __autoreleasing *)error {
    if (_patternTemplate == nil) {
        return NO;
    }
    return [super bindObjects:error];
}

@end
