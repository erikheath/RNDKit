//
//  RNDBindingTask.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/15/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindingTask.h"

@interface RNDBindingTask()


@end

@implementation RNDBindingTask

- (NSDictionary<RNDProcessorQueueName, void(^)(void)> *_Nullable)bindingTasks {
    dispatch_block_t processor = self.processorTask;
    return processor != nil ? @{_processorQueueName: processor} : nil;
}


@end
