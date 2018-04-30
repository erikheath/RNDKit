//
//  RNDIncrementalStore.m
//  RNDKit
//
//  Created by Erikheath Thomas on 4/26/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDIncrementalStore.h"

// Register in the app - provide a startup routine that can be added to application did finish launching. The store type is RNDIncrementalStoreType. The subclass of this will be the RNDRemoteStoreType.

@implementation RNDIncrementalStore

- (BOOL)loadMetadata:(NSError * _Nullable __autoreleasing *)error {
    
    return NO;
}

- (id)executeRequest:(NSPersistentStoreRequest *)request
         withContext:(NSManagedObjectContext *)context
               error:(NSError * _Nullable *)error {
    
    return nil;
}

- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                         withContext:(NSManagedObjectContext *)context
                                               error:(NSError * _Nullable *)error {

    return nil;
}

- (id)newValueForRelationship:(NSRelationshipDescription *)relationship
              forObjectWithID:(NSManagedObjectID *)objectID
                  withContext:(NSManagedObjectContext *)context
                        error:(NSError * _Nullable *)error {
    
    return nil;
}

- (NSArray<NSManagedObjectID *> *)obtainPermanentIDsForObjects:(NSArray<NSManagedObject *> *)array
                                                         error:(NSError * _Nullable *)error {
    return nil;
}

+ (id)identifierForNewStoreAtURL:(NSURL *)storeURL {
    return nil;
}

- (void)managedObjectContextDidRegisterObjectsWithIDs:(NSArray<NSManagedObjectID *> *)objectIDs {
    return;
}

- (void)managedObjectContextDidUnregisterObjectsWithIDs:(NSArray<NSManagedObjectID *> *)objectIDs {
    
}

@end


