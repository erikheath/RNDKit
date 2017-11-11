//
//  RNDSimpleValueBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"

/**
 The RNDSimpleValueBinder enables reading, writing, or read/write connections between an object acting as a model and an object acting as an observer/editor.
 
 In readOnlyMode and readOnlyMonitorMode, the binder maintains one binding object that connects to and optionally monitors a model object that conforms to RNDObservable, typically a subclass of RNDController. On request, or when a change is detected in the model object, the binder object will request the current value of its binding object and write that value, after optionally transforming it with its value transformer, to the property of its observer object specified by the binder's observerKey property.
 
 In writeOnly mode, the binder maintains one binding object that connects to a model object that conforms to RNDObservable, typically a subclass of RNDController. On request, or when a change is detected in the editor object, the binder will set the new value on the model object via its binding object after optionally reverse transforming it with its value transformer.
 
 In readWrite mode, the binder maintains one binding object that connects to a model object that conforms to RNDObservable, typically a subclass of RNDController. In this mode the binder and its binding automatically synchronize the values of the model and the observer/editor.
 */
@interface RNDSimpleValueBinder : RNDBinder

@end
