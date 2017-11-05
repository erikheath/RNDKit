//
//  RNDInvocationBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/4/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "RNDBinding.h"

@protocol RNDBindableObject;

@interface RNDInvocationBinding : RNDBinding 

@property (readonly, nullable) SEL bindingSelector;
@property (readonly, nullable) id<RNDBindableObject> bindingSelectorTarget;
@property (strong, readonly, nullable) NSArray<NSString *> *bindingSelectorArguments;
@property (strong, nullable, readonly) NSPredicate *evaluator; // Predicate string with arguments replaced at rt
@property (strong, nullable, readonly) id<RNDBindableObject> evaluatedObject; // An argument string is replaced at runtime

- (NSInvocation * _Nullable)bindingObjectValueWithSubstitutionVariables:(NSDictionary * _Nullable)substitutions;
- (NSInvocation * _Nullable)bindingObjectValueForBindingTargetWithSubstitutionVariables:(NSDictionary * _Nullable)substitutions;
- (BOOL)evaluteBindingWithSubstitutionVariables:(NSDictionary * _Nullable)substitutions;
@end
