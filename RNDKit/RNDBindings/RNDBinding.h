//
//  RNDBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingConstants.h"

@class RNDBinder;

@interface RNDBinding : NSObject

@property (strong, nonnull, readonly) RNDBindingName name;
@property (strong, nonnull, readonly) id observedObject;
@property (strong, nonnull, readonly) NSString * observedKeyPath;
@property (strong, nonnull, readonly) NSDictionary<RNDBindingOption, id> *options;
@property (weak, readonly) RNDBinder * _Nullable binder;
@property (readonly) BOOL isBound;

@property (readonly) BOOL valueAsBool;
@property (readonly) NSInteger valueAsInteger;
@property (readonly) long valueAsLong;
@property (readonly) float valueAsFloat;
@property (readonly) double valueAsDouble;
@property (readonly, nullable) NSString * valueAsString;
@property (readonly, nullable) NSDate * valueAsDate;
@property (readonly, nullable) NSUUID * valueAsUUID;
@property (readonly, nullable) NSData * valueAsData;
@property (readonly, nullable) id valueAsObject;

+ (instancetype _Nonnull)bindingForBinder:(RNDBinder * _Nonnull)binder withObserved:(id _Nonnull )object keyPath:(NSString *_Nonnull)keyPath options:(NSDictionary<RNDBindingOption, id> * _Nullable)options;

- (instancetype _Nonnull )initWithBinder:(RNDBinder * _Nonnull)binder observed:(id _Nonnull )object keyPath:(NSString *_Nonnull)keyPath options:(NSDictionary<RNDBindingOption, id> * _Nullable)options NS_DESIGNATED_INITIALIZER;

- (void)bind;

- (void)unbind;

@end

