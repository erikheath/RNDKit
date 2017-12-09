//
//  RNDResourceManager.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/28/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindingConstants.h"
#import "RNDBinderSet.h"
#import "RNDResourceBinder.h"
#import "RNDResourceBinding.h"
#import "../RNDBindings/RNDBindingConstants.h"
#import "RNDResourceManager.h"

@interface RNDResourceManager()

@property (class, strong, nonnull, readonly) RNDResourceManager *sharedManager;
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
        
        // TODO: dispatch merged manifest construction on sync queue
        // TODO: load resources that should be preloaded

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
        NSDictionary *namespaceManifest = nil;
        RNDBinderSet *resourceBinderSet = nil;
        RNDResourceBinder *resourceBinder = nil;

        NSArray *components = [keyPath componentsSeparatedByString:@"."];
        if (components == nil || components.count < 3) {
            resourceValue = [super valueForKeyPath:keyPath];
            return;
        }
        
        NSString *namespaceID = components[0];
        NSString *binderSetID = components[1];
        NSString *binderID = components[2];
        
        namespaceManifest = self.mergedManifest[namespaceID];
        resourceBinder = [self.resources[namespaceID][binderSetID] binders][binderID];
        
        if (resourceBinder == nil && namespaceManifest == nil) {
            resourceValue = [super valueForKeyPath:keyPath];
            return;
        }
        
        // TODO: Convert to use the bundle method.
        if (resourceBinder == nil && namespaceManifest != nil) {
            if (self.resources[namespaceID] == nil) {
                [self.resources setObject:[NSMutableDictionary dictionary] forKey:namespaceID];
            }
            NSString *binderSetURLString = namespaceManifest[binderSetID][RNDBinderManifestBinderSetURLKey];
            if (binderSetURLString == nil) {
                resourceValue = RNDBindingBinderSetNotFoundMarker;
                return;
            }
            NSURL *binderSetURL = [NSURL URLWithString:binderSetURLString];
            NSError *error = nil;
            resourceBinderSet = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfURL:binderSetURL options:NSDataReadingUncached error:&error]];
            if (resourceBinderSet == nil) {
                resourceValue = RNDBindingLoadingErrorMarker;
                return;
            } // The binder set can not be loaded at this time. Return the error marker.
            
            resourceBinderSet.observer = self;
            [resourceBinderSet bind:&error];
            if (error != nil) {
                resourceValue = RNDBindingUnboundErrorMarker;
                [resourceBinderSet unbind:nil];
                return;
            }
            [self.resources[namespaceID] setObject:resourceBinderSet forKey:binderSetID];
            
            resourceBinder = [self.resources[namespaceID][binderSetID] binders][binderID];
            if (resourceBinder == nil) {
                resourceValue = RNDBindingBinderNotFoundMarker;
                return;
            }
        }
        
        if (resourceBinder != nil) {
            resourceValue = resourceBinder.bindingObjectValue;
            // TODO: Insert the other markers
            if ([resourceValue isEqualToString:RNDBindingLoadingMarker] ||
                [resourceValue isEqualToString:RNDBindingLoadingErrorMarker]) {
                return;
            }
            NSString *operatorKeyPath = [[components subarrayWithRange:NSMakeRange(3, components.count)] componentsJoinedByString:@"."];
            resourceValue = [operatorKeyPath isEqualToString:@""] == YES ? resourceBinder.bindingObjectValue : [resourceBinder.bindingObjectValue valueForKeyPath:operatorKeyPath];
            return;
        }

    });

    return resourceValue;
}


@end
