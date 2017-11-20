//
//  RNDMultiValueBooleanBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"



/**
 The RNDMultiValueBooleanBinder enables the reading of values from multiple model objects that conform to RNDObservable and the subsequent generation of a boolean value based on the logical AND'ing or OR'ing of those values.
 
 A value is provided to the binder via a binding object, however the binder does not have to have a binding object to generate a value on request. By default, the value of the binder is false, however a delegate object can override that value and return true.
 
 This binder is a read only binder which means it can not write to its model objects, but it can update the values of its observer when requested or automatically when its model object(s) change.
 
 The binder may be in logical AND mode, in which as the andedValue property will be YES (true). Otherwise, the binder is in logical OR mode and the andedValue property will be NO (false).
 */
@interface RNDMultiValueBooleanBinder : RNDBinder

@property (readonly, getter=isAndedValue) BOOL andedValue;

@end
