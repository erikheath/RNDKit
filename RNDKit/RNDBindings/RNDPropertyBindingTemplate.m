//
//  RNDPropertyBindingExpression.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/14/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDPropertyBindingTemplate.h"
#import <objc/runtime.h>

@interface RNDPropertyBindingTask()

@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;
@property (strong, nullable, readonly) NSUUID *syncQueueIdentifier;

@end

@implementation RNDPropertyBindingTask

#pragma mark - Properties
@synthesize observer = _observer;
@synthesize observedObject = _observedObject;
@synthesize observedObjectKeyPath = _observedObjectKeyPath;
@synthesize observedObjectBindingIdentifier = _observedObjectBindingIdentifier;
@synthesize monitorsObservedObject = _monitorsObservedObject;
@synthesize processorQueueName = _processorQueueName;
@synthesize controllerKey = _controllerKey;
@synthesize bindingName = _bindingName;
@synthesize bindingIdentifier = _bindingIdentifier;
@synthesize isBound = _isBound;
@synthesize syncQueue = _syncQueue;
@synthesize syncQueueIdentifier = _syncQueueIdentifier;
@synthesize associatedTasks = _associatedTasks;

#pragma mark - Object Lifecycle
- (instancetype)init {
    if ((self = [super init]) != nil) {
        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
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
                [propertyName isEqualToString:@"isBound"] ||
                [propertyName isEqualToString:@"observedObject"]) { continue; }
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
        if (propertyCount > 0) {
            free(properties);
        }
        
        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        
        
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
            [propertyName isEqualToString:@"isBound"] ||
            [propertyName isEqualToString:@"observedObject"]) { continue; }
        [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    if (propertyCount > 0) {
        free(properties);
    }
}


#pragma mark - Binding Management

- (NSDictionary<RNDProcessorQueueName, void(^)(void)> *_Nullable)bindingTasks {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.processorTask != nil) {
        [dictionary setObject:self.processorTask forKey:_processorQueueName];
    }
    return dictionary;
}

-(void(^)(void))processorTask {
    dispatch_block_t blocktype = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
        
    });
    dispatch_block_wait(blocktype, DISPATCH_TIME_FOREVER);
    return ^{
        NSString *keyPath = _controllerKey == nil ? _observedObjectKeyPath : [NSString stringWithFormat:@"%@.%@", _controllerKey, _observedObjectKeyPath];
        _observedObject = [_observer objectForBindingIdentifier: _observedObjectBindingIdentifier];
        
        if (_monitorsObservedObject == YES) {
            [_observedObject addObserver: self
                              forKeyPath: keyPath
                                 options: NSKeyValueObservingOptionNew
                                 context: (__bridge void * _Nullable)(_bindingName)];
        }
        
        if (_monitorsObservedObject == YES) {
            [_observedObject removeObserver: self
                                 forKeyPath: keyPath
                                    context: (__bridge void * _Nullable)(_bindingName)];
        }
    };
}


#pragma mark - Key Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (context == NULL || context == nil) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else if ([(__bridge NSString * _Nonnull)(context) isKindOfClass: [NSString class]] == NO || [(__bridge NSString * _Nonnull)(context) isEqualToString:_bindingName] == NO) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if (change[NSKeyValueChangeNotificationIsPriorKey] != nil) {
        // TODO: Delegate calls?
    } else {
        if ([change[NSKeyValueChangeOldKey] isEqual:change[NSKeyValueChangeNewKey]] == YES) { return; }
        [_observer evaluateProcessorQueue:_processorQueueName];
    }
}


@end




