//
//  RNDInvocationBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/4/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "RNDBinding.h"

@protocol RNDBindableObject;

@interface RNDInvocationBinding : RNDBinding 

@property (readonly, nonnull) SEL bindingSelector;
@property (readonly, nullable) id<RNDBindableObject> bindingSelectorTarget;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@end
