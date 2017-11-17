//
//  RNDBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingTask.h"

@class RNDPropertyBindingTask;

@interface RNDBinding : NSObject <NSCoding, RNDBindingTaskQueueCoordinator>

#pragma mark - Binding Tasks
@property (strong, nonnull, readonly) NSMutableDictionary<NSString *, NSMutableArray<RNDBindingTask *> *> *processors;

#pragma mark - Binding Identification
@property (copy, nonnull, readwrite) NSString *bindingName;
@property (copy, nonnull, readwrite) NSString *bindingIdentifier;
@property (copy, nonnull, readwrite) NSString *bindingProcessorName;

#pragma mark - Coordination Queues
@property (strong, nonnull, readonly) dispatch_queue_t syncQueue;
@property (strong, nonnull, readonly) dispatch_queue_t bindingQueue;
@property (strong, nonnull, readonly) dispatch_queue_t unbindingQueue;
@property (strong, nonnull, readonly) dispatch_queue_t processorQueue;

#pragma mark - Binding Marker Substitutions
@property (strong, nullable, readwrite) id nullPlaceholder;
@property (strong, nullable, readwrite) id multipleSelectionPlaceholder;
@property (strong, nullable, readwrite) id noSelectionPlaceholder;
@property (strong, nullable, readwrite) id notApplicablePlaceholder;

#pragma mark - Object Lifecycle
- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;
-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

#pragma mark - Binding Management
- (void)bind;
- (BOOL)bind:(NSError * __autoreleasing _Nonnull * _Nonnull)error;
- (void)unbind;
- (BOOL)unbind:(NSError * __autoreleasing _Nonnull * _Nonnull)error;

@end

