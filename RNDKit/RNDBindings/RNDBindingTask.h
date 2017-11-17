//
//  RNDBindingTask.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/15/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingConstants.h"

@protocol RNDBindingTaskQueueCoordinator <NSObject>

- (void)evaluateProcessorQueue:(RNDProcessorQueueName _Nonnull )queueName;
- (id _Nullable )objectForBindingIdentifier:(NSString *_Nonnull)bindingIdentifier;

@end

@interface RNDBindingTask: NSObject <NSCoding>

@property (strong, nonnull, readwrite) RNDProcessorQueueName processorQueueName;
@property (strong, nonnull, readwrite) void(^processorTask)(void);

- (NSDictionary<RNDProcessorQueueName, void(^)(void)> *_Nullable)bindingTasks; // Returns blocks for the tasks that can be run on a target dispatch queue.

- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;

-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

@end
