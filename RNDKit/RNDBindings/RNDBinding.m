//
//  RNDBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBinding.h"
#import "RNDPropertyBindingTask.h"
#import "RNDBindingConstants.h"
#import "NSObject+RNDObjectBinding.h"
#import <objc/runtime.h>

@interface RNDBinding ()

@property (strong, nullable, readonly) NSUUID *syncQueueIdentifier;
@property (strong, nullable, readonly) NSUUID *bindingQueueIdentifier;
@property (strong, nullable, readonly) NSUUID *unbindingQueueIdentifier;
@property (strong, nullable, readonly) NSUUID *processorQueueIdentifier;

@property (strong, nonnull, readonly) NSDictionary<RNDProcessorQueueName, dispatch_queue_t> *allBindingQueues;
@property (strong, nonnull, readonly) dispatch_group_t unbindingGroup;


@end

@implementation RNDBinding

#pragma mark - Properties
@synthesize processors = _processors;

@synthesize bindingName = _bindingName;
@synthesize bindingIdentifier = _bindingIdentifier;
@synthesize bindingProcessorName = _bindingProcessorName;

@synthesize nullPlaceholder = _nullPlaceholder;
@synthesize multipleSelectionPlaceholder = _multipleSelectionPlaceholder;
@synthesize notApplicablePlaceholder = _notApplicablePlaceholder;
@synthesize noSelectionPlaceholder = _noSelectionPlaceholder;

@synthesize syncQueue = _syncQueue;
@synthesize bindingQueue = _bindingQueue;
@synthesize unbindingQueue = _unbindingQueue;
@synthesize processorQueue = _processorQueue;
@synthesize allBindingQueues = _allBindingQueues;
@synthesize unbindingGroup = _unbindingGroup;

@synthesize syncQueueIdentifier = _syncQueueIdentifier;
@synthesize bindingQueueIdentifier = _bindingQueueIdentifier;
@synthesize unbindingQueueIdentifier = _unbindingQueueIdentifier;
@synthesize processorQueueIdentifier = _processorQueueIdentifier;


#pragma mark - Object Lifecycle
- (instancetype)init {
    if ((self = [super init]) != nil) {

        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);

        _bindingQueueIdentifier = [[NSUUID alloc] init];
        _bindingQueue = dispatch_queue_create([[_bindingQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);

        _unbindingQueueIdentifier = [[NSUUID alloc] init];
        _unbindingQueue = dispatch_queue_create([[_unbindingQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        dispatch_suspend(_unbindingQueue);

        _processorQueueIdentifier = [[NSUUID alloc] init];
        _processorQueue = dispatch_queue_create([[_processorQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL);
        
        _allBindingQueues = @{ @"bindingQueue":_bindingQueue, @"unbindingQueue":_unbindingQueue, @"processorQueue":_processorQueue };
        
        _unbindingGroup = dispatch_group_create();
        dispatch_group_notify(_unbindingGroup, _unbindingQueue, ^{
            dispatch_suspend(_unbindingQueue);
            // NOTE: When the tasks in a group complete, the group will suspend
            // the queue so that it is ready for the next tasks.
        });
        

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init]) != nil) {
        
        uint propertyCount;
        objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
            if ([propertyName isEqualToString:@"syncQueue"] ||
                [propertyName isEqualToString:@"syncQueueIdentifier"] ||
                [propertyName isEqualToString:@"bindingQueue"] ||
                [propertyName isEqualToString:@"bindingQueueIdentifier"] ||
                [propertyName isEqualToString:@"unbindingQueue"] ||
                [propertyName isEqualToString:@"unbindingQueueIdentifier"] ||
                [propertyName isEqualToString:@"processorQueue"] ||
                [propertyName isEqualToString:@"processorQueueIdentifier"] ||
                [propertyName isEqualToString:@"allBindingQueues"] ||
                [propertyName isEqualToString:@"unbindingGroup"]) { continue; }
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
        if (propertyCount > 0) {
            free(properties);
        }
        
        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        
        _bindingQueueIdentifier = [[NSUUID alloc] init];
        _bindingQueue = dispatch_queue_create([[_bindingQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        
        _unbindingQueueIdentifier = [[NSUUID alloc] init];
        _unbindingQueue = dispatch_queue_create([[_unbindingQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT_INACTIVE);
        
        _processorQueueIdentifier = [[NSUUID alloc] init];
        _processorQueue = dispatch_queue_create([[_processorQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL);
        
        _allBindingQueues = @{ @"bindingQueue":_bindingQueue, @"unbindingQueue":_unbindingQueue, @"processorQueue":_processorQueue };

        _unbindingGroup = dispatch_group_create();

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    uint propertyCount;
    objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
        if ([propertyName isEqualToString:@"syncQueue"] ||
            [propertyName isEqualToString:@"syncQueueIdentifier"] ||
            [propertyName isEqualToString:@"bindingQueue"] ||
            [propertyName isEqualToString:@"bindingQueueIdentifier"] ||
            [propertyName isEqualToString:@"unbindingQueue"] ||
            [propertyName isEqualToString:@"unbindingQueueIdentifier"] ||
            [propertyName isEqualToString:@"processorQueue"] ||
            [propertyName isEqualToString:@"processorQueueIdentifier"] ||
            [propertyName isEqualToString:@"allBindingQueues"] ||
            [propertyName isEqualToString:@"unbindingGroup"]) { continue; }
        [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    if (propertyCount > 0) {
        free(properties);
    }
}

#pragma mark - Binding Management

- (void)addBindingTasks:(NSDictionary<RNDProcessorQueueName, void(^)(void)> *_Nullable)tasks {
    for (RNDProcessorQueueName queueName in tasks) {
        if ([queueName isEqualToString:@"unbindingQueue"]) {
            dispatch_group_async(_unbindingGroup, _unbindingQueue, tasks[queueName]);
            // NOTE: This adds the unbinding task to the unbinding group which
            // is on the unbinding queue which is suspended until unbind is called.
        } else {
            dispatch_async(_allBindingQueues[queueName], tasks[queueName]);
        }
    }
}

- (void)bind {
    dispatch_barrier_async(_syncQueue, ^{
        
    });
}

- (BOOL)bind:(NSError * _Nonnull __autoreleasing *)error {
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        for (RNDBindingTask *task in _processors[_bindingProcessorName]) {
            NSDictionary *bindingTasks = task.bindingTasks;
            if (bindingTasks == nil) {
                // TODO: Error Handling
                break;
            }
            [self addBindingTasks:bindingTasks];
            // NOTE: One of the issues to consider is how to propagate an error that
            // happens when tasks are added. Should it just be logged?
        }
        result = YES;
    });
    return result;
}

- (void)unbind {
    dispatch_barrier_async(_syncQueue, ^{
        dispatch_resume(_unbindingQueue);
        // NOTE: Unbinding tasks are added as a group. When the group completes, there is a
        // completion task that will suspend the queue.
        
        dispatch_group_wait(_unbindingGroup, DISPATCH_TIME_FOREVER);
        // NOTE: This block waits until all of the unbinding within the unbinding group
        // has completed to prevent additional blocks from being added to the group
        // accidentally through the bind methods.
    });
}

- (BOOL)unbind:(NSError * _Nonnull __autoreleasing *)error {
    __block BOOL result = NO;
    dispatch_barrier_sync(_syncQueue, ^{
        dispatch_resume(_unbindingQueue);
        dispatch_group_wait(_unbindingGroup, DISPATCH_TIME_FOREVER);
        
        // NOTE: Unbinding tasks are added as a group. When the group completes, there is a
        // completion task that will suspend the queue.

        // TODO: Error Handling
        result = YES;
    });
    return result;
}

- (void)evaluateProcessorQueue:(RNDProcessorQueueName)processorQueue {
    for (RNDBindingTask *task in _processors[processorQueue]) {
        id bindingTasks = task.bindingTasks;
        if (bindingTasks == nil) { continue; }
        [self addBindingTasks:bindingTasks];
    }
}


@end
