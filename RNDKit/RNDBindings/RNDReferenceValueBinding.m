//
//  RNDStaticValueBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/9/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDReferenceValueBinding.h"


@implementation RNDReferenceValueBinding

#pragma mark - Properties

@synthesize expressionType = _expressionType;
@synthesize expressionFunctionName = _expressionFunctionName;
@synthesize expressionTemplate = _expressionTemplate;
@synthesize evaluates = _evaluates;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        id rawObjectValue;
        if (_expressionTemplate != nil) {
            NSMutableArray *argumentArray = [NSMutableArray array];
            for (RNDBinding *binding in self.bindingArguments) {
                id argumentValue = binding.bindingObjectValue;
                if (argumentValue == nil) { argumentValue = [NSNull null]; }
                [argumentArray addObject:argumentValue];
            }
            rawObjectValue = [NSExpression expressionWithFormat:_expressionTemplate argumentArray:argumentArray];
        } else {
            rawObjectValue = [self expressionForKnownExpressionType];
        }
        
        if (_evaluates == NO) {
            objectValue = rawObjectValue;
        } else {
            NSMutableDictionary *workingDictionary = [NSMutableDictionary dictionary];
            objectValue = [rawObjectValue expressionValueWithObject:self.evaluatedObject context:workingDictionary];
            objectValue = self.valueTransformer != nil ? [self.valueTransformer transformedValue:objectValue] : objectValue;
        }
        
        if (objectValue == nil && self.nullPlaceholder != nil) {
            objectValue = self.nullPlaceholder;
        }
        
    });
    
    return objectValue;
}

- (NSExpression *)expressionForKnownExpressionType {
    id rawObjectValue = nil;
    
    switch (_expressionType) {
        case NSConstantValueExpressionType:
        {
            rawObjectValue = [NSExpression expressionForConstantValue:self.bindingArguments.firstObject.bindingObjectValue];
            break;
        }
        case NSEvaluatedObjectExpressionType:
        {
            rawObjectValue = [NSExpression expressionForEvaluatedObject];
            break;
        }
        case NSVariableExpressionType:
        {
            rawObjectValue = [NSExpression expressionForVariable:self.bindingArguments.firstObject.bindingObjectValue];
            break;
        }
        case NSKeyPathExpressionType:
        {
            rawObjectValue = [NSExpression expressionForKeyPath:self.bindingArguments.firstObject.bindingObjectValue];
            break;
        }
        case NSFunctionExpressionType:
        {
            NSMutableArray *argumentArray = [NSMutableArray array];
            for (RNDBinding *binding in self.bindingArguments) {
                id argumentValue = binding.bindingObjectValue;
                if (argumentValue == nil) { argumentValue = [NSNull null]; }
                [argumentArray addObject:argumentValue];
            }
            rawObjectValue = [NSExpression expressionForFunction:_expressionFunctionName arguments:argumentArray];
            break;
        }
        case NSAggregateExpressionType:
        {
            NSMutableArray *argumentArray = [NSMutableArray array];
            for (RNDBinding *binding in self.bindingArguments) {
                id argumentValue = binding.bindingObjectValue;
                if (argumentValue == nil) { argumentValue = [NSNull null]; }
                [argumentArray addObject:argumentValue];
            }
            rawObjectValue = [NSExpression expressionForAggregate:argumentArray];
            break;
        }
        case NSSubqueryExpressionType:
        {
            NSMutableArray *argumentArray = [NSMutableArray array];
            for (RNDBinding *binding in self.bindingArguments) {
                id argumentValue = binding.bindingObjectValue;
                if (argumentValue == nil) { argumentValue = [NSNull null]; }
                [argumentArray addObject:argumentValue];
            }
            rawObjectValue = [NSExpression expressionForSubquery:argumentArray.firstObject
                                           usingIteratorVariable:argumentArray[1]
                                                       predicate:argumentArray[2]];
            break;
        }
        case NSUnionSetExpressionType:
        {
            rawObjectValue = [NSExpression expressionForUnionSet:self.bindingArguments.firstObject.bindingObjectValue with:self.bindingArguments[1].bindingObjectValue];
            break;
        }
        case NSIntersectSetExpressionType:
        {
            rawObjectValue = [NSExpression expressionForIntersectSet:self.bindingArguments.firstObject.bindingObjectValue with:self.bindingArguments[1].bindingObjectValue];
            break;
        }
        case NSMinusSetExpressionType:
        {
            rawObjectValue = [NSExpression expressionForMinusSet:self.bindingArguments.firstObject.bindingObjectValue with:self.bindingArguments[1].bindingObjectValue];
            break;
        }
        case NSAnyKeyExpressionType:
        {
            rawObjectValue = [NSExpression expressionForAnyKey];
            break;
        }
        case NSConditionalExpressionType:
        {
            rawObjectValue = [NSExpression expressionForConditional:self.bindingArguments.firstObject.bindingObjectValue trueExpression:self.bindingArguments[1].bindingObjectValue falseExpression:self.bindingArguments[2].bindingObjectValue];
            break;
        }
            
        default:
            break;
    }
    return rawObjectValue;
}


#pragma mark - Object Lifecycle
- (instancetype)init {
    return [self initWithCoder:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _expressionType = [aDecoder decodeIntegerForKey:@"expressionType"];
        _expressionTemplate = [aDecoder decodeObjectForKey:@"expressionTemplate"];
        _expressionFunctionName = [aDecoder decodeObjectForKey:@"expressionFunctionName"];
        _evaluates = [aDecoder decodeBoolForKey:@"evaluates"];

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (aCoder == nil) { return; }
    [aCoder encodeInteger:_expressionType forKey:@"expressionType"];
    [aCoder encodeObject:_expressionTemplate forKey:@"expressionTemplate"];
    [aCoder encodeObject:_expressionFunctionName forKey:@"expressionFunctionName"];
    [aCoder encodeBool:_evaluates forKey:@"evaluates"];
}

@end
