//
//  RNDBindingAdaptor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

// TODO: Perhaps add prepares bindings? And a zero init?

#import <Foundation/Foundation.h>
#import "RNDBinder.h"
#import "RNDBindingConstants.h"
#import "RNDEditor.h"

@interface RNDBindingAdaptor : NSObject <RNDEditor, NSCoding>

@property (weak, readwrite, nullable) id observer;
@property (strong, readonly, nonnull) NSDictionary<RNDBindingName, RNDBinder *> *binders;
@property (strong, readonly, nonnull) NSString *identifier;

+ (instancetype _Nullable)adaptorForObject:(id _Nonnull)observer identifier:(NSString * _Nonnull)identifier;
- (instancetype _Nullable )initWithObject:(id _Nonnull)observer identifier:(NSString * _Nonnull)identifier NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)init;
- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

//Working with Bindings
- (BOOL)connectAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)disconnectAllBindings:(NSError * _Nullable __autoreleasing * _Nullable)error;
-(BOOL)removeBinding:(nonnull RNDBindingName)bindingName error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

