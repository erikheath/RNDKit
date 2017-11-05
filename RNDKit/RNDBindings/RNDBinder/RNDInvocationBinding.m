//
//  RNDInvocationBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/4/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDInvocationBinding.h"
#import "RNDBinder.h"
#import "../NSObject+RNDObjectBinding.h"
#import <objc/runtime.h>

@implementation RNDInvocationBinding

#pragma mark - Properties
@synthesize bindingSelector = _bindingSelector;
@synthesize bindingSelectorTarget = _bindingSelectorTarget;
@synthesize bindingSelectorArguments = _bindingSelectorArguments;
@synthesize evaluator = _evaluator;
@synthesize evaluatedObject = _evaluatedObject;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: [NSObject methodSignatureForSelector:_bindingSelector]];
        if (invocation != nil) {
            [invocation retainArguments];
            [invocation setSelector:_bindingSelector];
        }
        objectValue = invocation;
    });
    
    return objectValue == nil ? [NSNull null] : objectValue;
}

- (void)setBindingObjectValue:(id)bindingObjectValue {
    return;
}

- (BOOL)valueAsBool {
    return NO;
}

- (NSInteger)valueAsInteger {
    return 0;
}

- (long)valueAsLong {
    return 0;
}

- (float)valueAsFloat {
    return 0.0;
}

- (double)valueAsDouble {
    return 0.0;
}

- (NSString *)valueAsString {
    return [self.bindingObjectValue description];
}

- (NSDate *)valueAsDate {
    return nil;
}

- (NSUUID *)valueAsUUID {
    return nil;
}

- (NSData *)valueAsData {
    return nil;
}


#pragma mark - Object Lifecycle
- (instancetype)init {
    return [self initWithCoder:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _bindingSelector = NSSelectorFromString([aDecoder decodeObjectForKey:@"bindingSelector"]);
        _bindingSelectorArguments = [aDecoder decodeObjectForKey:@"bindingSelectorArguments"];
        _evaluator = [aDecoder decodeObjectForKey:@"evaluator"];
        _evaluatedObject = nil;
        
        NSString *evaluatedObjectKey = [aDecoder decodeObjectForKey:@"evaluatedObject"];
        if (evaluatedObjectKey != nil) {
            NSUInteger index = [self.binder.observer.bindingDestinations indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([((id<RNDBindableObject>)obj).bindingIdentifier isEqualToString: evaluatedObjectKey]) {
                    *stop = YES;
                }
                return NO;
            }];
            if (index != NSNotFound) {
                _evaluatedObject = self.binder.observer.bindingDestinations[index];
            }
        }
    }
    
    if (self.observedObject != nil && self.observedObjectKeyPath != nil) {
        _bindingSelectorTarget = [self.observedObject valueForKeyPath:self.observedObjectKeyPath];
    } else if (self.observedObject != nil) {
        _bindingSelectorTarget = self.observedObject;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:NSStringFromSelector(_bindingSelector) forKey:@"bindingSelector"];
    [aCoder encodeObject:_bindingSelectorArguments forKey:@"bindingSelectorArguments"];
    [aCoder encodeObject:_evaluator forKey:@"evaluator"];
    if (_evaluatedObject != nil) {
        [aCoder encodeObject:_evaluatedObject.bindingIdentifier forKey:@"evaluatedObject"];
    }
}

#pragma mark - Invocation Processing

- (NSInvocation * _Nullable)bindingObjectValueWithSubstitutionVariables:(NSDictionary *_Nullable)substitutions {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        NSInvocation *invocation = self.bindingObjectValue;
        if (invocation == nil || [invocation isEqual:[NSNull null]]) { return; }
        [_bindingSelectorArguments enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSObject *argument = [substitutions[obj] isKindOfClass:[NSNull class]] == NO ? substitutions[obj] : nil;
            [invocation setArgument:&argument atIndex:idx + 2];
        }];
        objectValue = invocation;
    });
    return objectValue == nil ? [NSNull null] : objectValue;

}

- (NSInvocation * _Nullable)bindingObjectValueForBindingTargetWithSubstitutionVariables:(NSDictionary *)substitutions {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        NSInvocation *invocation = [self bindingObjectValueWithSubstitutionVariables:substitutions];
        if (invocation == nil || [invocation isEqual:[NSNull null]] || _bindingSelectorTarget == nil) { return; }
        [invocation setTarget:_bindingSelectorTarget];
        objectValue = invocation;
    });
    return objectValue == nil ? [NSNull null] : objectValue;

}

#pragma mark - Evaluator Processing
- (BOOL)evaluteBindingWithSubstitutionVariables:(NSDictionary *)substitutions {
    BOOL __block result = nil;
    
    dispatch_sync(self.syncQueue, ^{
        result = [_evaluator evaluateWithObject:_evaluatedObject substitutionVariables:substitutions];
        
    });
    return result;

}


@end

