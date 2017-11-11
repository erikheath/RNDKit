//
//  RNDBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../RNDBindingConstants.h"
#import "../NSObject+RNDObjectBinding.h"

@class RNDBinder;

@interface RNDBinding : NSObject <NSCoding>

@property (strong, nullable, readonly) NSObject *observedObject;
@property (strong, nonnull, readonly) NSString * observedObjectKeyPath;
@property (strong, nonnull, readonly) NSString *observedObjectBindingIdentifier;
@property (readonly) BOOL monitorsObservedObject;

@property (strong, nonnull, readonly) NSString *controllerKey;
@property (weak, nullable, readonly) RNDBinder * binder;
@property (strong, nullable, readonly) NSString *bindingName;
@property (readwrite, nullable) id bindingObjectValue; // TODO: If the value is a placeholder, you can't write to it.

@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;
@property (readonly) BOOL isBound;

@property (strong, nullable, readonly) id nullPlaceholder;
@property (strong, nullable, readonly) id multipleSelectionPlaceholder;
@property (strong, nullable, readonly) id noSelectionPlaceholder;
@property (strong, nullable, readonly) id notApplicablePlaceholder;

@property (strong, nullable, readonly) NSString *argumentName;
@property (strong, nullable, readonly) NSString *valueTransformerName;


- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;

-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

- (void)bind;
- (BOOL)bind:(NSError * __autoreleasing _Nonnull * _Nonnull)error;

- (void)unbind;
- (BOOL)unbind:(NSError * __autoreleasing _Nonnull * _Nonnull)error;

@end

