//
//  RNDMultiValuePredicateBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"



/**
 The RNDMultiValuePredicateBinder enables the construction of a set of predicates that can be used to provide filtering options in search boxes, column headers, or any other scenario where uses can choose from a set of named options that correspond to a predicate.
 
 This binder manages one or more bindings that connect to a data source and provide named arguments to the binder. The binder maintains an array of user facing strings, an array of predicates, and a combined dictionary where the keys are the user facing strings that correspond to a predicate. Both keys and predicates may contain arguments that will be replaced when the binder value is requested. For example, a key can be "Recent search results for $PERSONNAME" and a corresponding predicate could be "personName==$PERSONNAME". The key uses NSRegularExpression replacement syntax and the predicate uses NSPredicate replacement syntax.
 
 This binder is a read only binder which means it can not write to its model objects, but it does update the values of its observer when requested.

 */
@interface RNDMultiValuePredicateBinder : RNDBinder

@property (strong, nonnull, readonly) NSArray *predicates;
@property (strong, nonnull, readonly) NSArray *userStrings;
@property (strong, nonnull, readonly) NSDictionary *keyedPredicates;

@end
