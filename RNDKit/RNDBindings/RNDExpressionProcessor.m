//
//  RNDExpressionProcessor.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/9/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDExpressionProcessor.h"
#import "RNDPredicateProcessor.h"


@implementation RNDExpressionProcessor

#pragma mark - Properties

@synthesize expressionTemplate = _expressionTemplate;

- (void)setExpressionTemplate:(NSString * _Nullable)expressionTemplate {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _expressionTemplate = expressionTemplate;
    });
}

- (NSString * _Nullable)expressionTemplate {
    NSString __block *localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _expressionTemplate;
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

        id rawObjectValue;
        NSMutableDictionary *argumentDictionary = [NSMutableDictionary dictionary];
        for (RNDBindingProcessor *binding in self.boundProcessorArguments) {
            id argumentValue = binding.bindingValue;
            if (argumentValue == nil) { argumentValue = [NSNull null]; }
            [argumentDictionary setObject:argumentValue forKey:binding.argumentName];
        }
        if (self.runtimeArguments != nil) {
            [argumentDictionary addEntriesFromDictionary:self.runtimeArguments];
        }
        
        rawObjectValue = [NSExpression expressionWithFormat:_expressionTemplate];
        
        if (self.processorOutputType == RNDRawValueOutputType) {
            objectValue = rawObjectValue;
        } else {
            objectValue = [rawObjectValue expressionValueWithObject:self.observedObjectBindingValue context:argumentDictionary];
            
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
        _expressionTemplate = [aDecoder decodeObjectForKey:@"expressionTemplate"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (aCoder == nil) { return; }
    [aCoder encodeObject:_expressionTemplate forKey:@"expressionTemplate"];
}

#pragma mark - Binding Management
-(BOOL)bindObjects:(NSError * _Nullable __autoreleasing *)error {
    if (_expressionTemplate == nil) {
        return NO;
    }
    return [super bindObjects:error];
}

@end
