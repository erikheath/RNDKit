//
//  RNDIncrementalStore.m
//  RNDKit
//
//  Created by Erikheath Thomas on 4/26/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDIncrementalStore.h"

@implementation RNDIncrementalStore

@synthesize rowCache = _rowCache;

@synthesize dataRequestDelegateQueue = _dataRequestDelegateQueue;

- (RNDRowCache *)rowCache {
    if (_rowCache == nil) {
        _rowCache = [RNDRowCache new];
    }
    return _rowCache;
}

- (NSURLCache *)dataCache {
    if (_dataCache == nil) {
        _dataCache = [NSURLCache sharedURLCache];
    }
    return _dataCache;
}

- (NSOperationQueue *)dataRequestDelegateQueue {
    if (_dataRequestDelegateQueue == nil) {
        _dataRequestDelegateQueue = [[NSOperationQueue alloc] init];
    }
    return _dataRequestDelegateQueue;
}

- (NSURLSession *)dataRequestSession {
    if (_dataRequestSession == nil) {
        _dataRequestSession = [NSURLSession sessionWithConfiguration:self.dataRequestConfigfuration delegate:self.dataRequestDelegate delegateQueue:self.dataRequestDelegateQueue];
    }
    return _dataRequestSession;
}

- (NSURLSessionConfiguration *)dataRequestConfigfuration {
    if (_dataRequestConfigfuration == nil) {
        _dataRequestConfigfuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // TODO: Configure the session configuration object.
        _dataRequestConfigfuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    return _dataRequestConfigfuration;
}

- (RNDQueryItemPredicateParser *)dataRequestQueryItemPredicateParser {
    if (_dataRequestQueryItemPredicateParser == nil) {
        _dataRequestQueryItemPredicateParser = [RNDQueryItemPredicateParser new];
    }
    return _dataRequestQueryItemPredicateParser;
}

- (BOOL)loadMetadata:(NSError *__autoreleasing *)error {
    
    NSMutableDictionary *mutableMetadata = [NSMutableDictionary dictionary];
    [mutableMetadata setValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:NSStoreUUIDKey];
    [mutableMetadata setValue:NSStringFromClass([self class]) forKey:NSStoreTypeKey];
    [self setMetadata:mutableMetadata];
    
    return YES;
}

- (id)executeRequest:(NSPersistentStoreRequest *)request
         withContext:(NSManagedObjectContext *)context
               error:(NSError * _Nullable *)error {
    
    if ([request requestType] == NSFetchRequestType) {
        NSFetchRequest *fetchRequest = (NSFetchRequest *)request;
        NSEntityDescription *entity = [fetchRequest entity];
        NSURL *serviceURL = nil;
        NSString *serviceURLString = nil;
        NSURLComponents *serviceComponents = nil;
        
        
        //****************** BEGIN DELEGATE URL PROCESSING ******************//
        if (self.dataRequestDelegate != nil) {
            if ([self.dataRequestDelegate respondsToSelector:@selector(storeShouldDelegateURLComponentConstructionForRequest:)] == YES && [self.dataRequestDelegate storeShouldDelegateURLComponentConstructionForRequest:fetchRequest] == YES) {
                serviceComponents = [self.dataRequestDelegate URLComponentsForRequest:fetchRequest];
            } else if ([self.dataRequestDelegate respondsToSelector:@selector(storeShouldDelegateURLTemplateConstructionForRequest:)] == YES && [self.dataRequestDelegate storeShouldDelegateURLTemplateConstructionForRequest:fetchRequest] == YES) {
                serviceURLString = [self.dataRequestDelegate URLTempateForRequest:fetchRequest];
            }
        }
        //****************** END DELEGATE URL PROCESSING ******************//

        
        //****************** BEGIN MODEL URL PROCESSING ******************//
        if (serviceComponents == nil && serviceURLString == nil) {
            serviceURLString = entity.userInfo[@"serviceURL"];
        }
        //****************** END MODEL URL PROCESSING ******************//

        
        //****************** BEGIN STORE URL PROCESSING ******************//
        if (serviceComponents == nil && serviceURLString == nil) {
            serviceURLString = [self.URL absoluteString];
        }
        //****************** END STORE URL PROCESSING ******************//

        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        if (serviceComponents == nil && serviceURLString == nil) { return nil; }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////

        
        //****************** BEGIN SUBSTITUTION VARIABLE PROCESSING ******************//
        // TODO: Add Default Substitutions
        if (serviceURLString != nil) {
            if (self.dataRequestDelegate != nil && [self.dataRequestDelegate respondsToSelector:@selector(storeShouldSubstituteVariablesForRequest:)] == YES && [self.dataRequestDelegate storeShouldSubstituteVariablesForRequest:fetchRequest] == YES) {
                NSDictionary *substitutionDictionary = [self.dataRequestDelegate substitutionDictionaryForRequest:fetchRequest defaultSubstitutions:@{}];
                for (NSString *variableName in substitutionDictionary) {
                    serviceURLString = [serviceURLString stringByReplacingOccurrencesOfString:variableName
                                                                                   withString:substitutionDictionary[variableName]];
                }
            }
        }
        //****************** END SUBSTITUTION VARIABLE PROCESSING ******************//

        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////

        if (serviceComponents == nil && serviceURLString == nil) { return nil; }
        
        if (serviceComponents == nil && serviceURLString != nil) {
            serviceComponents = [NSURLComponents componentsWithString:serviceURLString];
        }
        
        if (serviceComponents == nil) { return nil; }
        
        // TODO: Error Reporting
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////

        
        //****************** BEGIN QUERY ITEM PROCESSING ******************//

        NSMutableArray *queryItems = [NSMutableArray arrayWithArray:serviceComponents.queryItems];
        [queryItems addObjectsFromArray:[self.dataRequestQueryItemPredicateParser queryItemsForPredicateRepresentation:fetchRequest.predicate]];
        //****************** END QUERY ITEM PROCESSING ******************//

        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        [serviceComponents setQueryItems: queryItems];
        serviceURL = [serviceComponents URL];
        if (serviceURL == nil) { return nil; }
        
        // TODO: Error Reporting
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////

        
        //****************** BEGIN REQUEST DATA PROCESSING ******************//
        // In this initial processing, it's necessary to get the file
        // with the keys, whether that's from the cache or the server.
        NSError *serviceError = nil;
        NSData *serviceData = [self responseDataForServiceURL:serviceURL
                                     requestingEntity:entity
                                                error:&serviceError];
        //****************** END REQUEST DATA PROCESSING ******************//

        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////

        if (serviceError != nil) {
            if (error != NULL) {
                *error = serviceError;
                return nil;
            }
        }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////

        
        //*********************************************************

        // Retrieve the primary keys from the data
        // This makes the assumption that the data is returned in a JSON format
        // TODO: Create separate error declarations
        // TODO: Enable branching to different processors - XML, JSON, Plist, etc.
        // In the case of the JSON, it should return JSON, then process based on
        // some processing template. The template should enable the return of
        // an array of unique identifiers for the fetched entity. This will be useful
        // because it means that you could reroot the processor and have it process
        // other parts of the JSON for other purposes.
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
        //*********************************************************

        //*********************************************************
        // It will be necessary to insert row cache logic in here.
        // When the context requests an object,
        
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

- (NSData *)responseDataForServiceURL:(NSURL *)serviceURL
                     requestingEntity:(NSEntityDescription *)entity
                                error:(NSError * _Nullable *)error {
    
    NSURLRequestCachePolicy policy = self.dataRequestSession.configuration.requestCachePolicy;
    NSURLRequest *serviceRequest = [self serviceRequestForServiceURL:serviceURL requestingEntity:entity];
    if (serviceRequest == nil) { return nil; }
    NSCachedURLResponse *cachedResponse = [self cachedResponseForServiceRequest:serviceRequest requestingEntity:entity];
    
    if (policy == NSURLRequestReturnCacheDataDontLoad) {
        return cachedResponse != nil ? cachedResponse.data : nil;
        
    } else if (policy == NSURLRequestReloadIgnoringCacheData ||
               policy == NSURLRequestReloadIgnoringLocalCacheData ||
               policy == NSURLRequestReloadIgnoringLocalAndRemoteCacheData) {
        return [self responseForServiceRequest:serviceRequest error:error];
        
    } else if (policy == NSURLRequestReturnCacheDataElseLoad ||
               policy == NSURLRequestReloadRevalidatingCacheData) {
        return cachedResponse != nil && cachedResponse.data != nil ? cachedResponse.data : [self responseForServiceRequest:serviceRequest error:error];
    }
    return nil;
}

- (NSURLRequest *)serviceRequestForServiceURL:(NSURL *)URL
                             requestingEntity:(NSEntityDescription *)entity {
    NSTimeInterval serviceRequestTimeout = 20.0; // This is the default timeout.
    NSNumber *entityTimeout = entity.userInfo[@"serviceRequestTimeout"]; // An entity timeout may be set in the model.
    if (entityTimeout != nil) { serviceRequestTimeout = entityTimeout.doubleValue; }
    
    NSURLRequest *serviceRequest = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:serviceRequestTimeout];
    
    return serviceRequest;
}

- (NSCachedURLResponse *)cachedResponseForServiceRequest:(NSURLRequest *)serviceRequest
                                        requestingEntity:(NSEntityDescription *)entity {
    
    NSCachedURLResponse *cachedResponse = [self.dataCache cachedResponseForRequest:serviceRequest];
    if (cachedResponse == nil) { return nil; }
    
    NSString *stalenessFactorString = entity.userInfo[@"stalenessFactor"];
    if (stalenessFactorString == nil) { stalenessFactorString = @"86400"; }
    
    NSTimeInterval stalenessInterval = [stalenessFactorString doubleValue] * -1.0;
    NSDate *stalenessDate = [NSDate dateWithTimeIntervalSinceNow:stalenessInterval];
    if ([cachedResponse.response isKindOfClass: [NSHTTPURLResponse class]] == NO) { return nil; } // This is it for now.
    
    NSDictionary *headers = ((NSHTTPURLResponse *)cachedResponse.response).allHeaderFields;
    NSString *cachedResponseDateString = headers[@"Date"];
    if (cachedResponseDateString == nil) { return nil; }
    
    NSDateFormatter *cachedResponseDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [cachedResponseDateFormatter setLocale:locale];
    [cachedResponseDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [cachedResponseDateFormatter setDateFormat:@"EEE', 'dd' 'MMM' 'yyyy' 'HH':'mm':'ss' 'zzz"];
    NSDate *cachedResponseDate = [cachedResponseDateFormatter dateFromString:cachedResponseDateString];
    if (cachedResponseDate == nil) { return nil; }
    
    NSComparisonResult result = [stalenessDate compare:cachedResponseDate];
    if (result == NSOrderedDescending) {
        [self.dataCache removeCachedResponseForRequest:serviceRequest];
        return nil;
    }
    
    return cachedResponse;
}

- (NSData *)responseForServiceRequest:(NSURLRequest *)serviceRequest
                                error:(NSError * _Nullable *)error {
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSData * __block serviceData = nil;
    NSError * __block serviceError = nil;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // TODO: Implement Delegate Branching if needed.
        NSURLSessionDataTask *task = [self.dataRequestSession dataTaskWithRequest:serviceRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
    return serviceData;
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
    serviceData = [self responseDataForServiceURL:serviceURL
                                 requestingEntity:entity
                                            error:&serviceError];
    
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
        NSString *uniqueIdentifier = [self referenceObjectForObjectID:objectID];
        NSURL *serviceURL = [NSURL URLWithString:uniqueIdentifier];
        serviceData = [self responseDataForServiceURL:serviceURL
                                     requestingEntity:entity
                                                error:&serviceError];
        
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


