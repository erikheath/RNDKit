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

@property (strong, nullable, readonly) NSObject *observedObject;
@property (strong, nullable, readonly) NSString * observedObjectKeyPath;
@property (strong, nonnull, readonly) NSString *observedObjectBindingIdentifier;
@property (readonly) BOOL monitorsObservedObject;
@property (strong, nullable, readonly) RNDPredicateBinding *evaluator;
@property (strong, nullable, readonly) id evaluatedObject;


@property (strong, nonnull, readonly) NSString *controllerKey;
@property (weak, nullable, readonly) RNDBinder * binder;
@property (strong, nullable, readonly) NSString *bindingName;
@property (strong, nullable, readonly) RNDPatternedBinding *userString;
@property (readwrite, nullable) id bindingObjectValue; // TODO: If the value is a placeholder, you can't write to it.

@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@property (readonly) BOOL isBound;

@property (strong, nullable, readonly) RNDBinding *nullPlaceholder;
@property (strong, nullable, readonly) RNDBinding *multipleSelectionPlaceholder;
@property (strong, nullable, readonly) RNDBinding *noSelectionPlaceholder;
@property (strong, nullable, readonly) RNDBinding *notApplicablePlaceholder;
@property (strong, nullable, readonly) RNDBinding *nilPlaceholder;

@property (strong, nullable, readonly) NSString *argumentName;
@property (strong, nullable, readonly) NSString *valueTransformerName;
@property (strong, nullable, readonly) NSValueTransformer *valueTransformer;
@property (strong, readonly, nullable) NSArray<RNDBinding *> *bindingArguments;
@property (strong, null_resettable, readwrite) NSDictionary<NSString *, id> *runtimeArguments;



- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;

-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

- (void)bind;
- (BOOL)bind:(NSError * __autoreleasing _Nonnull * _Nonnull)error;

- (void)unbind;
- (BOOL)unbind:(NSError * __autoreleasing _Nonnull * _Nonnull)error;

@end

