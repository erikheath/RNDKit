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
@class NSAttributeDescription;

@interface RNDBinding : NSObject <NSCoding>

@property (strong, nullable, readonly) NSObject *observedObject;
@property (strong, nonnull, readonly) NSString * observedObjectKeyPath;
@property (strong, nonnull, readonly) NSString *observedObjectBindingIdentifier;
@property (readonly) BOOL monitorsObservedObject;

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

// RNDConvertable Protocol
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



- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;

-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

- (void)bind;

- (void)unbind;

@end

