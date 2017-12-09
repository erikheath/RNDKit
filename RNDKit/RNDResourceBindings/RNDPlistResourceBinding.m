//
//  RNDPlistResourceBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/29/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDPlistResourceBinding.h"
#import "../RNDBindings/RNDPredicateBinding.h"

@implementation RNDPlistResourceBinding
#pragma mark - Properties
@synthesize mutabilityType = _mutabilityType;

- (void)setMutabilityType:(NSPropertyListMutabilityOptions)mutabilityType {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _mutabilityType = mutabilityType;
    });
}

- (NSPropertyListMutabilityOptions)mutabilityType {
    NSPropertyListMutabilityOptions __block localObject = 0;
    dispatch_sync(self.syncQueue, ^{
        localObject = _mutabilityType;
    });
    return localObject;
}

#pragma mark - Calculated (Transient) Properties
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
        
        id replacableObjectValue;
        if (self.bindingArguments.count == 1) {
            id argumentObjectValue = self.bindingArguments.firstObject.bindingObjectValue;
            NSError *error = nil;
            
            if ([argumentObjectValue isKindOfClass:[NSURL class]]) {
                argumentObjectValue = [NSData dataWithContentsOfURL:argumentObjectValue options:NSDataReadingUncached error:&error];
                // TODO: Error handling
            }
            
            if ([argumentObjectValue isKindOfClass:[NSData class]]){
                argumentObjectValue = [NSPropertyListSerialization propertyListWithData:argumentObjectValue options:_mutabilityType format:nil error:&error];
                // TODO: Error handling
            }
            replacableObjectValue = argumentObjectValue;
        } else {
            replacableObjectValue = RNDBindingInvalidArgumentMarker;
        }
        
        
        if ([replacableObjectValue isEqual: RNDBindingInvalidArgumentMarker] == YES) {
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
    return [super init];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _mutabilityType = [aDecoder decodeIntegerForKey:@"mutabilityType"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_mutabilityType forKey:@"mutabilityType"];
}

#pragma mark - Binding Management

@end
