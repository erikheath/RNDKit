//
//  RNDBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingConstants.h"
#import "NSObject+RNDObjectBinding.h"

@class RNDBinder;
@class RNDPatternedBinding;
@class RNDPredicateBinding;

@interface RNDBinding : NSObject <NSCoding>

@property (strong, nullable, readwrite) NSObject *observedObject;
@property (strong, nullable, readwrite) NSString * observedObjectKeyPath;
@property (strong, nullable, readwrite) NSString *observedObjectBindingIdentifier;
@property (readwrite) BOOL monitorsObservedObject;
@property (strong, nullable, readwrite) RNDPredicateBinding *evaluator;
@property (strong, nullable, readonly) id evaluatedObject;


@property (strong, nonnull, readwrite) NSString *controllerKey;
@property (weak, nullable, readwrite) RNDBinder * binder;
@property (strong, nullable, readwrite) NSString *bindingName;
@property (strong, nullable, readwrite) RNDPatternedBinding *userString;
@property (readwrite, nullable) id bindingObjectValue; // TODO: If the value is a placeholder, you can't write to it.

@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;

@property (readonly) BOOL isBound;

@property (strong, nullable, readwrite) RNDBinding *nullPlaceholder;
@property (strong, nullable, readwrite) RNDBinding *multipleSelectionPlaceholder;
@property (strong, nullable, readwrite) RNDBinding *noSelectionPlaceholder;
@property (strong, nullable, readwrite) RNDBinding *notApplicablePlaceholder;
@property (strong, nullable, readwrite) RNDBinding *nilPlaceholder;

@property (strong, nullable, readwrite) NSString *argumentName;
@property (strong, nullable, readwrite) NSString *valueTransformerName;
@property (strong, nullable, readonly) NSValueTransformer *valueTransformer;
@property (strong, readwrite, nullable) NSMutableArray<RNDBinding *> *bindingArguments;
@property (strong, nullable, readwrite) NSDictionary<NSString *, id> *runtimeArguments;
@property (strong, nonnull, readonly) NSArray<RNDBinding *> *allBindings;
@property (readwrite) BOOL evaluates;


- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;

-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

- (void)bind;
- (BOOL)bind:(NSError * __autoreleasing _Nullable * _Nullable)error;

- (void)unbind;
- (BOOL)unbind:(NSError * __autoreleasing _Nullable * _Nullable)error;

- (BOOL)bindObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;
- (BOOL)unbindObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;
@end

