//
//  RNDResourceManager.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/28/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDResource.h"
#import "../RNDBindings/RNDBindingConstants.h"
#import "RNDResourceManager.h"

@interface RNDResourceManager()

@property (class, strong, nonnull, readonly) RNDResourceManager *sharedManager;
@property (strong, nonnull, readonly) NSDictionary *mergedManifest;
@property (strong, nonnull, readonly) NSMutableDictionary<NSString *, NSMutableDictionary *> *resources;
@property (strong, nonnull, readonly) dispatch_queue_t syncQueue;
@property (strong, nonnull, readonly) NSUUID *syncQueueIdentifier;

@end

@implementation RNDResourceManager

#pragma mark - Properties
@synthesize mergedManifest = _mergedManifest;
@synthesize resources = _resources;
@synthesize syncQueue = _syncQueue;
@synthesize syncQueueIdentifier = _syncQueueIdentifier;

+ (RNDResourceManager *)sharedManager {
    static RNDResourceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RNDResourceManager alloc] init];
    });
    return manager;
}

#pragma mark - Object Lifecycle
- (instancetype)init {
    if((self = [super init]) != nil) {
        _resources = [NSMutableDictionary dictionary];
        
        _syncQueueIdentifier = [[NSUUID alloc] init];
        _syncQueue = dispatch_queue_create([[_syncQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        
        // TODO: dispatch merged on sync queue

    }
    return self;
}

#pragma mark - Access Methods
+ (RNDResourceManager *)resourceManager {
    
    return self.sharedManager;
}

- (id)valueForKeyPath:(NSString *)keyPath {
    id __block resourceValue = nil;
    dispatch_barrier_sync(_syncQueue, ^{
        NSMutableDictionary *resourceNamespace = nil;
        NSDictionary *namespaceManifest = nil;
        
        NSArray *components = [keyPath componentsSeparatedByString:@"."];
        if (components == nil || components.count < 2) {
            resourceValue = nil;
            return;
        } // The keyPath is invalid.
        resourceNamespace = self.resources[components[0]];
        namespaceManifest = self.mergedManifest[components[0]];
        if (resourceNamespace == nil && namespaceManifest != nil) {
            [self.resources setObject:[NSMutableDictionary dictionary] forKey:components[0]];
        } else if (resourceNamespace == nil && namespaceManifest == nil) {
            resourceValue = nil;
            return;
        } // There is no entry for this manifest in the merged manifest.
        
        components = [components subarrayWithRange:NSMakeRange(1, components.count)];
        resourceValue = [resourceNamespace valueForKeyPath:[components componentsJoinedByString:@"."]];
        if (resourceValue != nil) { return; }
        
        // If the resource isn't loaded yet...

        NSDictionary *resourceInfo = namespaceManifest[components[1]];
        if (resourceInfo == nil) {
            resourceValue = nil;
            return;
        } // There is no entry for this resource in the namespace manifest.
        
        NSError *error = nil;
        RNDResource *resource = [RNDResource resourceForInfo:resourceInfo error:&error]; // TODO: error handling
        [resourceNamespace setObject:resource forKey:components[1]];
        resourceValue = [resourceNamespace valueForKeyPath:[components componentsJoinedByString:@"."]];
    });

    return resourceValue;
}


@end
