//
//  RNDJSONParser.m
//  RNDKit
//
//  Created by Erikheath Thomas on 5/10/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDJSONParser.h"

@implementation RNDJSONParser

/*
 
 In Cocoa, our keypaths are "." separated. We do variable replacement using '$'.
 So how would we do a for each - i.e. continue processing, or do a selection
 from an array? Can you construct a predicate using expressions to drill into
 an arbitrary structure?
 
 key
 $variable
 
 root.data.foreach.id go from JSON Syntax into Expressions
 
 expressionForKeyPath:@"root.data" -> collection returns a collection when applied to an object.
 
 You can use a subquery to return only items that are compliant, which is possibly a way to prune out a collection of elements. For example, SUBQUERY(collection_expression, variable_expression, predicate) to return only items that have an id.
 
 root.data.@unionofobjects.id
 
 expressionForKeyPath:@"id" -> a string.
 
 */

@end
