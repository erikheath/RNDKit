//
//  RNDPropertyBindingExpression.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/14/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindingTask.h"

@interface RNDPropertyBindingTask: NSObject

@property (weak, nullable, readwrite) NSObject<RNDBindingTaskQueueCoordinator> *observer;
@property (strong, nullable, readwrite) NSObject *observedObject;
@property (strong, nonnull, readwrite) NSString *observedObjectKeyPath;
@property (strong, nonnull, readwrite) NSString *observedObjectBindingIdentifier;
@property (strong, nonnull, readwrite) NSString *controllerKey;
@property (readwrite) BOOL monitorsObservedObject;

@property (strong, nullable, readwrite) NSString *bindingName;
@property (strong, nullable, readwrite) NSString *bindingIdentifier;

- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;

-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

@end
