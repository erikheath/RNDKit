//
//  RNDMultiValueArgumentBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"

@class RNDBinding;
@class RNDInvocationBinding;


/**
 The RNDMultiValueArgumentBinder enables the construction of an invocation with varying number of arguments that can be sent to a target object.
 
 This binder has one or more bindings that connect to the properties of model objects and provide those values to the binder when requested. The values are treated as named arguments for the selector associated with the binder. This binder constructs an invocation based on the selector and arguments, and then executes the invocation for the target that has been set for the binding.
 
 It is possible to set more than one target for the binding and to vary the selector and/or arguments used in the invocation by associating a predicate with each selector. In this case, an invocation using the selector will only be invoked if the predicate returns true. You can further specialize the behavior of the binder by associating a specific target for a selector.
 
 This binder is a read only binder which means it can not write to its model objects, but it does update the values of its observer when requested.
 */
@interface RNDMultiValueArgumentBinder : RNDBinder

@property (strong, nonnull, readonly) NSArray<RNDInvocationBinding *> *targetArray;
@property (strong, nonnull, readonly) NSArray<RNDBinding *> *argumentsArray;
@property (readonly) NSUInteger controlEventMask;

@end
