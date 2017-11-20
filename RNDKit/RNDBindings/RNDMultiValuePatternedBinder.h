//
//  RNDMultiValuePatternedBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"

@class RNDPatternedBinding;

/**
 The RNDMultiValuePatternBinder enables the reading and subsequent construction of a string value based on values taken from the properties of one or more model objects.
 
 The binder defines a pattern string with named arguments. The named arguments correspond to the values of the binder's binding objects. When a binding object's value changes, or on request to the binder, the binder will request and substitute in the values for the named arguments present in its pattern string from its bindings. This enables the construction of pattern strings such as "Page $PAGENUM of $PAGECOUNT" where $PAGENUM is a value derived from one binding whose argumentName property is "PAGENUM", and $PAGECOUNT is a value derived from another binding whose argumentName property is "PAGECOUNT".
 
 
 This binder is a read only binder which means it can not write to its model objects, but it can update the values of its observer when requested or automatically when its model object(s) change.
 */
@interface RNDMultiValuePatternedBinder : RNDBinder

@property (strong, nonnull, readonly) NSArray<RNDPatternedBinding *> *patternedStrings;
@property (strong, nonnull, readonly) NSArray<RNDPatternedBinding *> *userStrings;
@property (readonly) BOOL filtersNilValues;
@property (readonly) BOOL filtersNonPatternValues;

@end
