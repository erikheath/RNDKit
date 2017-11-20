//
//  RNDMultiValueRegExBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"

@class RNDRegExBinding;
@class RNDPatternedBinding;

/**
 The RNDMultiValuePredicateBinder enables the construction of a set of regular expressions that can be used to provide content search options in search boxes or any other scenario where uses can choose from a set of named options that correspond to a regular expression.
 
 This binder manages one or more bindings that can connect to a data source. The binder is specialized to maintain an array of user facing strings, an array of RNDRegExBinding objects, and a combined dictionary where the keys are the user facing strings that correspond to a RNDRegExBinding. Keys may contain arguments that will be replaced when the binder value is requested. For example, a key can be "Find  $PERSONNAME in $CONTENTSECTION" where both $PERSONNAME and $CONTENTSECTION are replaced based on a user's selection.
 
 This binder is a read only binder which means it can not write to its model objects, but it does update the values of its observer when requested or when triggered.

 */
@interface RNDMultiValueRegExBinder : RNDBinder

@property (strong, nonnull, readonly) NSArray<RNDRegExBinding *> *regularExpressions;
@property (strong, nonnull, readonly) NSArray<RNDPatternedBinding *> *userStrings;
@property (strong, nonnull, readonly) NSDictionary *keyedRegularExpressions;
@property (readonly) BOOL filtersNilValues;
@property (readonly) BOOL filtersNonRegExValues;

@end
