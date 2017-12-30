//
//  RNDTargetActionBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"

@class RNDInvocationProcessor;

typedef NS_ENUM(NSUInteger, RNDBindingInvocationType) {
    RNDNoArgumentType,
    RNDSenderArgumentType,
    RNDSenderEventArgumentType
};

@interface RNDTargetActionBinder: RNDBinder

@property (strong, nonnull, readonly) RNDInvocationProcessor *bindingInvocationProcessor;
@property (strong, nonnull, readonly) RNDInvocationProcessor *unbindingInvocationProcessor;
@property (strong, nonnull, readonly) RNDInvocationProcessor *actionInvocationProcessor;

- (void)performBindingObjectAction;
- (void)performBindingObjectAction:(id _Nullable)sender;
- (void)performBindingObjectAction:(id _Nullable)sender forEvent:(id _Nullable)event;
- (void)performBindingObjectAction:(id _Nullable)sender forEvent:(id _Nullable)event withContext:(id _Nullable)context;
@end

