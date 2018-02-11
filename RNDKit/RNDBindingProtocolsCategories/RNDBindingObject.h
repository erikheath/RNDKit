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
@property (readonly) BOOL bound;

- (void)bind;
- (void)unbind;
- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error;

@optional
@property (strong, nullable, readonly) dispatch_queue_t coordinator;
@property (strong, nullable, readonly) NSUUID *coordinatorQueueIdentifier;
@property (nonnull, strong, readonly) dispatch_semaphore_t syncCoordinator;

- (BOOL)bindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;
- (BOOL)unbindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;

@end
