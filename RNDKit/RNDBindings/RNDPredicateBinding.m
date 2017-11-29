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

- (void)setPredicateFormatString:(NSString * _Nullable)predicateFormatString {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _predicateFormatString = predicateFormatString;
    });
}

- (NSString * _Nullable)predicateFormatString {
    NSString __block *localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _predicateFormatString;
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

        NSMutableDictionary * __block argumentsDictionary = [NSMutableDictionary dictionary];

        [self.bindingArguments enumerateObjectsUsingBlock:^(RNDBinding * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RNDBinding *binding = obj;
            id argumentValue = binding.bindingObjectValue;
            [argumentsDictionary setObject:argumentValue forKey:binding.argumentName];
        }];

        [argumentsDictionary addEntriesFromDictionary:self.runtimeArguments];

        NSPredicate *predicate = [[NSPredicate predicateWithFormat:_predicateFormatString]  predicateWithSubstitutionVariables: argumentsDictionary];
        
        if (self.evaluates == NO) {
            objectValue = predicate;
            return;
            // TODO: Error Handling
        } else {
            objectValue = @([predicate evaluateWithObject:self.evaluatedObject]);
            
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
        _predicateFormatString = [aDecoder decodeObjectForKey:@"predicateFormatString"];

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (aCoder == nil) { return; }
    [aCoder encodeObject:_predicateFormatString forKey:@"predicateFormatString"];

}

#pragma mark - Binding Management
-(BOOL)bindObjects:(NSError * _Nullable __autoreleasing *)error {
    if (_predicateFormatString == nil) {
        return NO;
    }
    return [super bindObjects:error];
}

@end
