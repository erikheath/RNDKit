//
//  RNDInvocationBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/4/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//


#import "RNDBindingTask.h"

@protocol RNDBindableObject;

@interface RNDInvocationBinding : RNDBindingTask

@property (readonly, nonnull) SEL bindingSelector;
@property (readonly, nullable) id<RNDBindableObject> bindingSelectorTarget;
@property (strong, readonly, nullable) NSArray<RNDBinding *> *bindingSelectorArguments;
@property (strong, nullable, readonly) NSPredicate *evaluator; // Predicate string with arguments replaced at rt
@property (strong, nullable, readonly) id<RNDBindableObject> evaluatedObject; // An argument string is replaced at runtime
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;


- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;

-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

-(BOOL)evaluate:(NSMutableDictionary * _Nonnull)context;

@end
