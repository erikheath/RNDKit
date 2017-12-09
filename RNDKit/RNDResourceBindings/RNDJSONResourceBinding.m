//
//  RNDJSONResourceBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/30/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDJSONResourceBinding.h"
#import "../RNDBindings/RNDPredicateBinding.h"

@implementation RNDJSONResourceBinding
#pragma mark - Properties
@synthesize mutableContainers = _mutableContainers;

- (void)setMutableContainers:(BOOL)mutableContainers {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _mutableContainers = mutableContainers;
    });
}

- (BOOL)mutableContainers {
    BOOL __block localObject = NO;
    dispatch_sync(self.syncQueue, ^{
        localObject = _mutableContainers;
    });
    return localObject;
}

@synthesize mutableLeaves = _mutableLeaves;

- (void)setMutableLeaves:(BOOL)mutableLeaves {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _mutableLeaves = mutableLeaves;
    });
}

- (BOOL)mutableLeaves {
    BOOL __block localObject = NO;
    dispatch_sync(self.syncQueue, ^{
        localObject = _mutableLeaves;
    });
    return localObject;
}

@synthesize allowsFragments = _allowsFragments;

- (void)setAllowsFragments:(BOOL)allowsFragments {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _allowsFragments = allowsFragments;
    });
}

- (BOOL)allowsFragments {
    BOOL __block localObject = NO;
    dispatch_sync(self.syncQueue, ^{
        localObject = _allowsFragments;
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
                argumentObjectValue = [NSJSONSerialization JSONObjectWithData:argumentObjectValue options:_mutableContainers | _mutableLeaves | _allowsFragments error:&error];
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
        _mutableContainers = [aDecoder decodeIntegerForKey:@"mutableContainers"];
        _mutableLeaves = [aDecoder decodeIntegerForKey:@"mutableLeaves"];
        _allowsFragments = [aDecoder decodeIntegerForKey:@"allowsFragments"];

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:_mutableContainers forKey:@"mutableContainers"];
    [aCoder encodeInteger:_mutableLeaves forKey:@"mutableLeaves"];
    [aCoder encodeInteger:_allowsFragments forKey:@"allowsFragments"];

}

#pragma mark - Binding Management

@end
