//
//  RNDCoordinatedDictionary.m
//  RNDKit
//
//  Created by Erikheath Thomas on 2/6/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDCoordinatedDictionary.h"

@implementation RNDCoordinatedDictionary

#pragma mark - Subclass Overrides
- (instancetype)initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    if ((self = [super initWithObjects:objects forKeys:keys count:cnt]) != nil) {
        _coordinatorQueueIdentifier = [[NSUUID alloc] init];
        _coordinator = dispatch_queue_create([[_coordinatorQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        _syncCoordinator = dispatch_semaphore_create(1);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _coordinatorQueueIdentifier = [[NSUUID alloc] init];
        _coordinator = dispatch_queue_create([[_coordinatorQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        _syncCoordinator = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSUInteger)count {
    NSUInteger __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = [super count];
    });
    return localObject;
}

- (id)objectForKey:(id)aKey {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = [super objectForKey:aKey];
    });
    return localObject;
}

- (NSEnumerator *)keyEnumerator {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = [super keyEnumerator];
    });
    return localObject;
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        [super setObject:anObject forKey:aKey];
    });
}

- (void)removeObjectForKey:(id)aKey {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        [super removeObjectForKey:aKey];
    });
}


#pragma mark - RNDBindingObject Protocol


@synthesize coordinator = _coordinator;

@synthesize coordinatorQueueIdentifier = _coordinatorQueueIdentifier;

@synthesize syncCoordinator = _syncCoordinator;

@synthesize bound = _isBound;

- (void)bind {
    <#code#>
}

- (BOOL)bind:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    <#code#>
}

- (void)unbind {
    <#code#>
}

- (BOOL)unbind:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    <#code#>
}

- (BOOL)bindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error {
    
}
- (BOOL)unbindCoordinatedObjects:(NSError * __autoreleasing _Nullable * _Nullable)error {
    
}
@end
