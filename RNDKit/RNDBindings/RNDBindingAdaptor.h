//
//  RNDBindingAdaptor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"
#import "RNDBindingConstants.h"
#import "RNDEditor.h"

@interface RNDBindingAdaptor : NSObject <RNDEditor>

@property (weak, readonly, nullable) id observer;
@property (strong, readonly, nonnull) NSDictionary<RNDBindingName, RNDBinder *> *binders;
@property (strong, readonly, nonnull) NSString *identifier;
@property (strong, readonly, nonnull) NSArray *exposedBindings;

+ (instancetype _Nonnull)adaptorForObject:(id _Nonnull)observer identifier:(NSString * _Nonnull)identifier;
- (instancetype _Nonnull )initWithObject:(id _Nonnull)observer identifier:(NSString * _Nonnull)identifier;

//Working with Bindings
- (BOOL)connectAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)removeAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)addBinding:(nonnull RNDBindingName)bindingName forObject:(nonnull id)observable withKeyPath:(nonnull NSString *)keyPath options:(nullable NSDictionary<RNDBindingOption,id> *)options error:(NSError * _Nullable __autoreleasing * _Nullable)error;
-(BOOL)removeBinding:(nonnull RNDBindingName)bindingName error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

