//
//  RNDBindingObjectValue.h
//  RNDKit
//
//  Created by Erikheath Thomas on 2/6/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RNDBindingObjectValue <NSObject>

#pragma mark - Binding Value Construction
@property (strong, readonly, nullable) id bindingValue;

- (id _Nullable)coordinatedBindingValue;
- (id _Nullable)rawBindingValue;
- (id _Nullable)calculatedBindingValue:(id _Nullable)bindingValue;
- (id _Nullable)filteredBindingValue:(id _Nullable)bindingValue;
- (id _Nullable)transformedBindingValue:(id _Nullable)bindingValue;
- (id _Nullable)wrappedBindingValue:(id _Nullable)bindingValue;

@end
