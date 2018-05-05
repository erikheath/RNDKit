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

- (BOOL)loadMetadata:(NSError *__autoreleasing *)error {
    // For a remote store, verfiying the URL doesn't generally make
    // sense.
    //    NSURL *storeURL = [self URL];
    // ... metadata validation
    // This UUID is unique for the store type.
    NSMutableDictionary *mutableMetadata = [NSMutableDictionary dictionary];
    [mutableMetadata setValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:NSStoreUUIDKey];
    [mutableMetadata setValue:NSStringFromClass([self class]) forKey:NSStoreTypeKey];
    [self setMetadata:mutableMetadata];
//    NSDictionary *metadata = @{NSStoreUUIDKey: @"com.unison.remotestore.porchlight",
//                               NSStoreTypeKey: @"RNDIncrementalStoreType"};
//    [self setMetadata:metadata];
    
    return YES;
}

- (id)executeRequest:(NSPersistentStoreRequest *)request
         withContext:(NSManagedObjectContext *)context
               error:(NSError * _Nullable *)error {
    
    // TODO: Handle basic fetch request.
    if ([request requestType] == NSFetchRequestType) {
        NSFetchRequest *fetchRequest = (NSFetchRequest *)request;
        NSEntityDescription *entity = [fetchRequest entity];
        
        // TODO: The request must include the sort which will order the primary keys and thus the returned objects. Also, it should support scope modifiers like max results, etc.
        NSData * __block serviceData = nil;
        NSError * __block serviceError = nil;
        
        // The basic URL pieces needed for any request in the current setup.
        NSURLComponents *serviceComponents = [NSURLComponents componentsWithString:@"http://porch-LoadB-IFMDLNXV2S4E-bdde94ba5bce560e.elb.us-east-1.amazonaws.com/api/v1/homes?distanceUnits=mi&page=1&perPage=200&columns=id&columns=marketId"];
        NSMutableArray *queryItems = [NSMutableArray arrayWithArray:serviceComponents.queryItems];
        
        if (([fetchRequest.predicate.predicateFormat containsString:@"city"] || [fetchRequest.predicate.predicateFormat containsString:@"postalCode"] ) && [fetchRequest.predicate isKindOfClass:[NSCompoundPredicate class]]) {
            // This is a request for a city, state based result set.
            for (NSComparisonPredicate *compareObject in ((NSCompoundPredicate *)fetchRequest.predicate).subpredicates) {
                NSString *constraint = compareObject.leftExpression.keyPath;
                NSString *value = compareObject.rightExpression.constantValue;
                [queryItems addObject:[NSURLQueryItem queryItemWithName:constraint value:value]];
            }
        }
//        } else if ([fetchRequest.predicate.predicateFormat containsString:@"id"]) {
//            // This is a request for a specific property id.
//            NSURLQueryItem *idItem = [NSURLQueryItem queryItemWithName:@"id" value:@""];
//            [queryItems addObject:idItem];
//        }
        [serviceComponents setQueryItems: queryItems];

        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithURL:[serviceComponents URL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error != nil) {
                    serviceError = error;
                    dispatch_semaphore_signal(sema);
                    return;
                }
                serviceData = data;
                dispatch_semaphore_signal(sema);
            }];
            [task resume];

        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

        if (serviceError != nil) {
            if (error != NULL) {
                *error = serviceError;
                return nil;
            }
        }
        
        // Retrieve the primary keys from the data
        id JSONResult = [NSJSONSerialization JSONObjectWithData:serviceData options:0 error:&serviceError];
        if(serviceError != nil) {
            if (error != NULL) {
                *error = serviceError;
                return nil;
            }
        }
        
        NSMutableArray *primaryKeys = [NSMutableArray array];
        NSArray *listingIdentifiers = [JSONResult objectForKey:@"data"];
        for (NSDictionary *listing in listingIdentifiers) {
            NSString *listingID = listing[@"id"];
            NSMutableString *URLString = [NSMutableString stringWithString:@"http://listi-LoadB-RYEUA1CVJ3N5-8c99f35991bf2249.elb.us-east-1.amazonaws.com/api/v1/listings/"];
            [URLString appendString:listingID];
            NSURL *serviceURL = [NSURL URLWithString: URLString]; // Validate that the URL works.
            if (serviceURL == nil) { continue; }
            [primaryKeys addObject: URLString];
        }
        
         // This is where the count of objects and the identifying keys comes from.
        NSMutableArray *fetchedObjects = [NSMutableArray arrayWithCapacity:[primaryKeys count]];
        for (NSString *primaryKey in primaryKeys) {
            NSManagedObjectID *objectID = [self newObjectIDForEntity:entity referenceObject:primaryKey];
            NSManagedObject *managedObject = [context objectWithID:objectID];
            [fetchedObjects addObject:managedObject];
        }
        
        return fetchedObjects;
    } else if ([request requestType] == NSSaveRequestType) {
//        NSSaveChangesRequest *saveRequest = (NSSaveChangesRequest *)request;
//        NSSet *insertedObjects = [saveRequest insertedObjects];
//        NSSet *updatedObjects = [saveRequest updatedObjects];
//        NSSet *deletedObjects = [saveRequest deletedObjects];
//        NSSet *optLockObjects = [saveRequest lockedObjects];
        
        // TODO: ... Perform any operations on your backing data store needed to persist the changes. set and increment version numbers.
        
        return @[];
    }
    return nil;
}

- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                         withContext:(NSManagedObjectContext *)context
                                               error:(NSError * _Nullable *)error {
    
    // We're only returning listings right now.
    
    NSMutableDictionary *values = [NSMutableDictionary new]; // TODO: This is where the data from the web service should be made available.
    uint64_t version = 0; // This should be returned from the backing store.
    
    NSEntityDescription *entity = [[context objectWithID:objectID] entity];
    
    NSData * __block serviceData = nil;
    NSError * __block serviceError = nil;
    
    // The basic URL pieces needed for any request in the current setup.
    NSURL *serviceURL = [NSURL URLWithString:[self referenceObjectForObjectID:objectID]];
    
    // This creates a synchronous workflow which is necessary for the current implementation.
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithURL:serviceURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                serviceError = error;
                dispatch_semaphore_signal(sema);
                return;
            }
            serviceData = data;
            dispatch_semaphore_signal(sema);
        }];
        [task resume];
        
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    if (serviceError != nil) {
        if (error != NULL) {
            *error = serviceError;
            return nil;
        }
    }
    
    // Branch based on the entity type. If this is an image request, then write the image.
    // Otherwise, traverse the data.
    if ([entity.name isEqualToString:@"UNSImage"]) {
        [values setObject:serviceData forKey:@"image"];
    } else {
        NSError *JSONResultError = nil;
        id JSONResult = [NSJSONSerialization JSONObjectWithData:serviceData options:0 error:&JSONResultError];
        if(JSONResultError != nil) {
            if (error != NULL) {
                *error = JSONResultError;
                return nil;
            }
        }
        if (JSONResult == nil) { return nil; }
        
        NSDictionary *listing = ((NSArray *)JSONResult[@"data"]).firstObject;
        if (listing == nil) { return nil; }
        
        // Populate the dictionary with values.
        for (NSAttributeDescription *attribute in entity) {
            if (attribute.userInfo[@"serverKeyPath"] != nil) {
                id serverValue = listing;
                for (NSString *keyPathComponent in [attribute.userInfo[@"serverKeyPath"] componentsSeparatedByString:@"."]) {
                    serverValue = [serverValue objectForKey:keyPathComponent];
                }
                if (serverValue != nil) { [values setObject:serverValue forKey:attribute.name]; }
            }

        }
        
        if (values.count < 1) { return nil; }
    }
    
    // Construct the node that will back the managed object.
    NSIncrementalStoreNode *node = [[NSIncrementalStoreNode alloc] initWithObjectID:objectID withValues:values version:version];
    
    return node;
}

- (id)newValueForRelationship:(NSRelationshipDescription *)relationship
              forObjectWithID:(NSManagedObjectID *)objectID
                  withContext:(NSManagedObjectContext *)context
                        error:(NSError * _Nullable *)error {
    
    
    NSEntityDescription *entity = relationship.entity;
    
    if (relationship.isToMany) {
        
        NSData * __block serviceData = nil;
        NSError * __block serviceError = nil;
        
        // The basic URL pieces needed for any request in the current setup.
        NSURL *serviceURL;
        
        NSString *uniqueIdentifier = [self referenceObjectForObjectID:objectID];
        serviceURL = [NSURL URLWithString:uniqueIdentifier];
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *task = [session dataTaskWithURL:serviceURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error != nil) {
                    serviceError = error;
                    dispatch_semaphore_signal(sema);
                    return;
                }
                serviceData = data;
                dispatch_semaphore_signal(sema);
            }];
            [task resume];
            
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        if (serviceError != nil) {
            if (error != NULL) {
                *error = serviceError;
                return nil;
            }
        }
        
        // Retrieve the primary keys from the data
        NSError *JSONResultError = nil;
        id JSONResult = [NSJSONSerialization JSONObjectWithData:serviceData options:0 error:&JSONResultError];
        
        // Check for conversion error.
        if(JSONResultError != nil) {
            if (error != NULL) {
                *error = JSONResultError;
                return nil;
            }
        }
        
        // Get the data object.
        NSDictionary *dataObject = ((NSArray *)JSONResult[@"data"]).firstObject;
        if (dataObject == nil) { return nil; }
        
        // Update the entity to represent the relationship object.
        entity = relationship.destinationEntity;
        
        // Return a raw array of server based IDs.
        NSMutableArray *relationshipObjectIDArray = [NSMutableArray array];
        id serverValue = dataObject;
        if (relationship.userInfo[@"serverKeyPath"] != nil) {
            for (NSString *keyPathComponent in [relationship.userInfo[@"serverKeyPath"] componentsSeparatedByString:@"."]) {
                serverValue = [serverValue objectForKey:keyPathComponent];
            }
        }
        if ([serverValue isKindOfClass:[NSArray class]] == NO) { return nil; }
        
        // Get the URL strings to use as reference object IDs.
        NSArray *rawIDArray = serverValue;
        for (NSString *URLEntry in rawIDArray) {
            NSURL *objectIDURL = [NSURL URLWithString:URLEntry]; // Test to make sure it's valid.
            if (objectIDURL != nil) {
                [relationshipObjectIDArray addObject:[self newObjectIDForEntity:entity referenceObject:URLEntry]];
            }
        }
        
        return relationshipObjectIDArray.count > 0 ? [NSArray arrayWithArray:relationshipObjectIDArray] : nil;
        
    } else {
        // Return an objectID. Note: Reference Objects only need to be unique within an entity.
        NSManagedObjectID *relationshipObjectID = [self newObjectIDForEntity:relationship.destinationEntity referenceObject:[self referenceObjectForObjectID:objectID]];
        return relationshipObjectID;
    }
    
    return nil;
}

- (NSArray<NSManagedObjectID *> *)obtainPermanentIDsForObjects:(NSArray<NSManagedObject *> *)array
                                                         error:(NSError * _Nullable *)error {
    NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSManagedObject *managedObject in array) {
        // TODO: This must vary by whether the object should be created locally, whether the objet is transient, etc.
        NSManagedObjectID *objectID = [self newObjectIDForEntity:managedObject.entity referenceObject:[NSUUID new].UUIDString];
        [objectIDs addObject:objectID];
    }
    
    return objectIDs;
    
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


