//
//  RNDBindingObject.h
//  RNDKit
//
//  Created by Erikheath Thomas on 1/15/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RNDBindingObject <NSObject>

#pragma mark - Binding Management
@property (readonly, getter=isBound) BOOL bound;

- (void)bind;
- (void)unbind;
- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (BOOL)bindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;
- (BOOL)unbindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;

#pragma mark - Binding Value Construction
@property (strong, readonly, nullable) id bindingValue;

- (id _Nullable)coordinatedBindingValue;
- (id _Nullable)rawBindingValue;
- (id _Nullable)calculatedBindingValue:(id _Nullable)bindingValue;
- (id _Nullable)filteredBindingValue:(id _Nullable)bindingValue;
- (id _Nullable)transformedBindingValue:(id _Nullable)bindingValue;
- (id _Nullable)wrappedBindingValue:(id _Nullable)bindingValue;

@end
