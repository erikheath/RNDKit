//
//  RNDBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingConstants.h"
#import "RNDBinding.h"
#import "RNDBindingInfo.h"

@class RNDBindingAdaptor;

@interface RNDBinder : NSObject <NSCoding>

@property (strong, nonnull, readonly) RNDBindingName name;
@property (nonnull, readonly) RNDBindingInfo * bindingInfo;
@property (nonnull, strong, readonly) NSArray<RNDBinding *> * bindings;
@property (weak, readwrite, nullable) RNDBindingAdaptor * adaptor;

- (instancetype _Nullable)init;
- (instancetype _Nullable)initWithName:(RNDBindingName _Nonnull )bindingName error:(NSError *__autoreleasing  _Nullable * _Nullable)error NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

- (BOOL)addBindingForObject:(id _Nonnull )observable withKeyPath:(NSString *_Nonnull)keyPath options:(NSDictionary<RNDBindingOption,id> *_Nullable)options error:(NSError *__autoreleasing  _Nullable * _Nullable)error;

- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
