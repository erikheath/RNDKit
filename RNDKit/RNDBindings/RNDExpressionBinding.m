//
//  RNDExpressionBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/9/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDExpressionBinding.h"
#import "RNDPredicateBinding.h"


@implementation RNDExpressionBinding

#pragma mark - Properties

@synthesize expressionTemplate = _expressionTemplate;

- (void)setExpressionTemplate:(NSString * _Nullable)expressionTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _expressionTemplate = expressionTemplate;
    });
}

- (NSString * _Nullable)expressionTemplate {
    NSString __block *localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _expressionTemplate;
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

        id rawObjectValue;
        NSMutableArray *argumentArray = [NSMutableArray array];
        for (RNDBinding *binding in self.bindingArguments) {
            id argumentValue = binding.bindingObjectValue;
            if (argumentValue == nil) { argumentValue = [NSNull null]; }
            [argumentArray addObject:argumentValue];
        }
        rawObjectValue = [NSExpression expressionWithFormat:_expressionTemplate argumentArray:argumentArray];
        
        if (self.evaluates == NO) {
            objectValue = rawObjectValue;
        } else {
            NSMutableDictionary *workingDictionary = [NSMutableDictionary dictionary];
            objectValue = [rawObjectValue expressionValueWithObject:self.evaluatedObject context:workingDictionary];
            
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
