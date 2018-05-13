//
//  RNDIncrementalStore.m
//  RNDKit
//
//  Created by Erikheath Thomas on 4/26/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDIncrementalStore.h"
#import "RNDJSONResponseProcessor.h"

@implementation RNDIncrementalStore


#pragma mark - Property Definitions

@synthesize rowCache = _rowCache;

@synthesize dataRequestDelegateQueue = _dataRequestDelegateQueue;
@synthesize dataResponseProcessors = _dataResponseProcessors;

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

- (NSOperationQueue *)dataResponseDelegateQueue {
    if (_dataRequestDelegateQueue == nil) {
        _dataRequestDelegateQueue = [[NSOperationQueue alloc] init];
    }
    return _dataRequestDelegateQueue;
}

- (NSMutableDictionary *)dataResponseProcessors {
    if (_dataResponseProcessors == nil) {
        _dataResponseProcessors = [NSMutableDictionary new];
    }
    return _dataResponseProcessors;
}


#pragma mark - Core Data Override Definitions

- (BOOL)loadMetadata:(NSError *__autoreleasing *)error {
    
    NSMutableDictionary *mutableMetadata = [NSMutableDictionary dictionary];
    [mutableMetadata setValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:NSStoreUUIDKey];
    [mutableMetadata setValue:NSStringFromClass([self class]) forKey:NSStoreTypeKey];
    [self setMetadata:mutableMetadata];
    
    //TODO: EXTERNAL CONFIGURATION FROM MODEL
    [self.dataResponseProcessors setObject:[RNDJSONResponseProcessor new] forKey:@"UNSListing"];
    [self.dataResponseProcessors setObject:[RNDJSONResponseProcessor new] forKey:@"UNSImage"];
    [self.dataResponseProcessors setObject:[RNDJSONResponseProcessor new] forKey:@"UNSProperty"];
    
    self.dataCacheExpirationInterval = 300;
    
    // END EXTERNAL CONFIGURATION FROM MODEL
    
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
        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        if (serviceComponents == nil && serviceURLString == nil) { return nil; }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////

        //****************** END STORE URL PROCESSING ******************//

        
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

        //****************** END SUBSTITUTION VARIABLE PROCESSING ******************//

        
        //****************** BEGIN QUERY ITEM PROCESSING ******************//

        NSMutableArray *queryItems = [NSMutableArray arrayWithArray:serviceComponents.queryItems];
        [queryItems addObjectsFromArray:[self.dataRequestQueryItemPredicateParser queryItemsForPredicateRepresentation:fetchRequest.predicate]];
        
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

        //****************** END QUERY ITEM PROCESSING ******************//

        
        //****************** BEGIN REQUEST DATA PROCESSING ******************//
        // In this initial processing, it's necessary to get the file
        // with the keys, whether that's from the cache or the server.
        BOOL ignoreCache = ((NSString *)entity.userInfo[@"ignoreCache"]).boolValue;
        NSError *serviceError = nil;
        NSData *serviceData = [self responseDataForServiceURL:serviceURL
                                             forRequestingEntity:entity
                                                  withContext:context
                                                   lastUpdate:nil
                                                  forceReload:ignoreCache
                                                        error:&serviceError];
        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////

        if (serviceError != nil && error != NULL) {
            *error = serviceError;
            return nil;
        }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////

        //****************** END REQUEST DATA PROCESSING ******************//

        
        //****************** BEGIN RESPONSE DATA PROCESSING ******************//
        NSError *dataProcessorError = nil;

        NSArray *primaryKeys = [self.dataResponseProcessors[entity.name] uniqueIdentifiersForEntity:entity responseData:serviceData error:&dataProcessorError];
        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        if (dataProcessorError != nil && error != NULL) {
            *error = dataProcessorError;
            return nil;
        }
        
        if (primaryKeys.count == 0) {
            return @[];
        }

        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        
        NSMutableArray *fetchedObjects = [NSMutableArray arrayWithCapacity:[primaryKeys count]];
        
        for (NSString *primaryKey in primaryKeys) {
            NSManagedObjectID *objectID = [self newObjectIDForEntity:entity referenceObject:primaryKey];
            NSManagedObject *managedObject = [context objectWithID:objectID];
            [fetchedObjects addObject:managedObject];
        }
        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        if (((NSString *)entity.userInfo[@"prefetch"]).boolValue == NO &&
            ((NSString *)entity.userInfo[@"preload"]).boolValue == NO) {
            return fetchedObjects;
        }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        
        //****************** END RESPONSE DATA PROCESSING ******************//

        
        //****************** BEGIN PREFETCH/PRELOAD PROCESSING ******************//
        
        NSDictionary *lastUpdated = [self.dataResponseProcessors[entity.name] lastUpdatesForEntity:entity objectIDs:fetchedObjects responseData:serviceData error:&serviceError];
        
        NSMutableArray * __block errorArray = [NSMutableArray new];
        
        dispatch_queue_t __block errorQueue = dispatch_queue_create("errorQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL, QOS_CLASS_USER_INITIATED, QOS_MIN_RELATIVE_PRIORITY));
        
        BOOL shouldPreload = ((NSString *)entity.userInfo[@"preload"]).boolValue;

        [primaryKeys enumerateObjectsWithOptions:NSEnumerationReverse
                                         usingBlock:^(id  _Nonnull primaryKey, NSUInteger idx, BOOL * _Nonnull stop) {
                                             NSError *prefetchError = nil;
                                             NSURL *serviceURL = [NSURL URLWithString:(NSString *)primaryKey];
                                             NSData *prefetchData = [self responseDataForServiceURL:serviceURL
                                                                                   forRequestingEntity:entity
                                                                                        withContext:context
                                                                                         lastUpdate:lastUpdated[primaryKey]
                                                                                        forceReload:ignoreCache
                                                                                              error:&prefetchError];
                                             
                                             //////////////////////////////////////////////////////
                                             ///////////////////// CHECKPOINT /////////////////////
                                             //////////////////////////////////////////////////////
                                             
                                             if (prefetchError != nil) {
                                                 dispatch_sync(errorQueue, ^{
                                                     [errorArray addObject:prefetchError];
                                                 });
                                                 return;
                                             }
                                             
                                             if (prefetchData == nil) {
                                                 // TODO: return Error
                                                 return;
                                             }
                                             
                                             if (shouldPreload == NO) { return; }
                                             
                                             /////////////////////////////////////////////////////
                                             //////////////////////////////////////////////////////
                                             //////////////////////////////////////////////////////
                                             
                                             NSError *preloadError = nil;
                                             NSIncrementalStoreNode *node = [self rowForPrimaryKey:primaryKey
                                                                                       forObjectID:fetchedObjects[idx]
                                                                                         forEntity:entity
                                                                                       withContext:context
                                                                                             error:&preloadError].node;
                                             
                                             //////////////////////////////////////////////////////
                                             ///////////////////// CHECKPOINT /////////////////////
                                             //////////////////////////////////////////////////////
                                             
                                             if (preloadError != nil) {
                                                 dispatch_sync(errorQueue, ^{
                                                     [errorArray addObject:preloadError];
                                                 });
                                                 return;
                                             }
                                             
                                             if (node == nil) {
                                                 // TODO: return Error
                                                 return;
                                             }
                                             
                                             /////////////////////////////////////////////////////
                                             //////////////////////////////////////////////////////
                                             //////////////////////////////////////////////////////
                                             
                                         }];
        
        // TODO: Set the error.
        // Decide on how to return objects if a prefetch or preload error occurs. It may
        // make the most sense to just return them if there was no originating error
        // as it could be the result of a network drop.
        if (errorArray.count > 0 && errorArray != NULL) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                code:150000
                                            userInfo:@{NSUnderlyingErrorKey:errorArray}];
        }
        
        return fetchedObjects;
        
        //****************** END PREFETCH/PRELOAD PROCESSING ******************//
        
    } else if ([request requestType] == NSSaveRequestType) {
        
        //        NSSaveChangesRequest *saveRequest = (NSSaveChangesRequest *)request;
        //        NSSet *insertedObjects = [saveRequest insertedObjects];
        //        NSSet *updatedObjects = [saveRequest updatedObjects];
        //        NSSet *deletedObjects = [saveRequest deletedObjects];
        //        NSSet *optLockObjects = [saveRequest lockedObjects];
        
        return @[];
    }
    return nil;
}

- (RNDRow *)rowForPrimaryKey:(NSString *)primaryKey
                 forObjectID:(NSManagedObjectID *)objectID
                   forEntity:(NSEntityDescription *)entity
                 withContext:(NSManagedObjectContext *)context
                       error:(NSError * _Nullable *)error {
    //****************** BEGIN EXISTING ROW PROCESSING ******************//
    // Check for an existing node. If it's valid, return it.
    // 1. Does it exist?
    // 2. Is it unexpired?
    // 3. Has the proxy store acquired newer info?
    // 4. Do I ignore the cache
    RNDRow *row = [self.rowCache rowForObjectID:objectID];
    NSDate *lastUpdate = [self lastUpdateForServiceURL:[NSURL URLWithString:primaryKey]
                                   forRequestingEntity:entity
                                           withContext:context];
    BOOL ignoreCache = ((NSString *)entity.userInfo[@"ignoreCache"]).boolValue;
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (ignoreCache == NO &&
        row != nil &&
        row.isExpried == NO &&
        lastUpdate != nil &&
        [lastUpdate compare:row.lastUpdated] != NSOrderedAscending) { // TODO: CHECK THIS - Last update should not be ahead of row
        return row;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END EXISTING ROW PROCESSING ******************//
    
    // IGNORE CACHE == YES -> Force Reload
    // NO ROW == YES -> Retrieve From Store Proxy
    // ROW EXPIRED == YES -> Retrieve From Store Proxy
    
    // If you don't pass in a last updated, then it is the date the file was downloaded.
    
    
    //****************** BEGIN DATA REQEUST PROCESSING ******************//
    
    NSData * __block serviceData = nil;
    NSError * __block serviceError = nil;
    
    NSURL *serviceURL = [NSURL URLWithString:primaryKey];
    
    serviceData = [self responseDataForServiceURL: serviceURL
                              forRequestingEntity: entity
                                      withContext:context
                                       lastUpdate: nil
                                      forceReload: ignoreCache
                                            error: &serviceError];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (serviceError != nil && error != NULL) {
        *error = serviceError;
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END DATA REQEUST PROCESSING ******************//
    
    
    //****************** BEGIN DATA RESPONSE PROCESSING ******************//
    NSDictionary *values = [self.dataResponseProcessors[entity.name] valuesForEntity:entity responseData:serviceData error:&serviceError];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (serviceError != nil && error != NULL) {
        *error = serviceError;
        return nil;
    }
    
    if (values == nil) {
        // TODO: return Error
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END DATA RESPONSE PROCESSING ******************//
    
    
    //****************** BEGIN ROW PROCESSING ******************//
    uint64_t version = 0;
    NSIncrementalStoreNode *node = nil;
    
    
    if (row != nil) {
        node = row.node;
        [node updateWithValues:values
                       version:node.version + 1];
    } else {
        NSTimeInterval expirationInterval = context.stalenessInterval < 0 ? 84000 : context.stalenessInterval;
        NSString *expirationIntervalString = entity.userInfo[@"entityExpirationInterval"];
        if (expirationIntervalString != nil) { expirationInterval = expirationIntervalString.doubleValue; }

        node = [[NSIncrementalStoreNode alloc] initWithObjectID:objectID withValues:values version:version];
        row = [[RNDRow alloc] initWithNode:node
                               lastUpdated:[self lastUpdateForServiceURL:serviceURL
                                                     forRequestingEntity:entity
                                                             withContext:context]
                        expirationInterval:expirationInterval];
    }
    
    return row;
    
    //****************** END ROW PROCESSING ******************//
}

- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                         withContext:(NSManagedObjectContext *)context
                                               error:(NSError * _Nullable *)error {
    
    NSString *primaryKey = [self referenceObjectForObjectID:objectID];
    NSEntityDescription *entity = [[context objectWithID:objectID] entity];
    NSIncrementalStoreNode *node = [self rowForPrimaryKey:primaryKey
                                              forObjectID:objectID
                                                forEntity:entity
                                              withContext:context
                                                    error:error].node;
    
    return node;

}


- (id)newValueForRelationship:(NSRelationshipDescription *)relationship
              forObjectWithID:(NSManagedObjectID *)objectID
                  withContext:(NSManagedObjectContext *)context
                        error:(NSError * _Nullable *)error {
    
    
    if (relationship.isToMany) {
        
        //****************** BEGIN DATA REQUEST PROCESSING ******************//
        BOOL ignoreCache = ((NSString *)relationship.entity.userInfo[@"ignoreCache"]).boolValue;
        NSError *serviceError = nil;
        NSURL *serviceURL = [NSURL URLWithString:[self referenceObjectForObjectID:objectID]];
        NSData *serviceData = [self responseDataForServiceURL:serviceURL
                                             forRequestingEntity:relationship.entity
                                                  withContext:context
                                                  lastUpdate:nil
                                                  forceReload:ignoreCache
                                                        error:&serviceError];
        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        if (serviceError != nil && error != NULL) {
            *error = serviceError;
            return nil;
        }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        
        //****************** END DATA REQUEST PROCESSING ******************//
        

        
        //****************** BEGIN RESPONSE DATA PROCESSING ******************//
        NSError *dataProcessorError = nil;
        
        NSArray *primaryKeys = [self.dataResponseProcessors[relationship.destinationEntity.name] uniqueIdentifiersForEntity:relationship.destinationEntity responseData:serviceData error:&dataProcessorError];
        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        if (dataProcessorError != nil && error != NULL) {
            *error = dataProcessorError;
            return nil;
        }
        
        if (primaryKeys.count == 0) {
            return nil;
        }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        
        NSMutableArray *objectIDArray = [NSMutableArray arrayWithCapacity:[primaryKeys count]];
        
        for (NSString *primaryKey in primaryKeys) {
            NSManagedObjectID *objectID = [self newObjectIDForEntity:relationship.destinationEntity referenceObject:primaryKey];
            [objectIDArray addObject:objectID];
        }
        
        //TODO: INSERT PREFETCH / PRELOAD LOGIC - perhaps a certain number
        
        return objectIDArray;
        
        //****************** END RESPONSE DATA PROCESSING ******************//
        
    } else {
        
        //****************** BEGIN DATA REQUEST PROCESSING ******************//
        BOOL ignoreCache = ((NSString *)relationship.entity.userInfo[@"ignoreCache"]).boolValue;
        NSError *serviceError = nil;
        NSURL *serviceURL = [NSURL URLWithString:[self referenceObjectForObjectID:objectID]];
        NSData *serviceData = [self responseDataForServiceURL:serviceURL
                                             forRequestingEntity:relationship.entity
                                                  withContext:context
                                                  lastUpdate:nil
                                                  forceReload:ignoreCache
                                                        error:&serviceError];
        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        if (serviceError != nil && error != NULL) {
            *error = serviceError;
            return nil;
        }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        
        //****************** END DATA REQUEST PROCESSING ******************//

        
        //****************** BEGIN DATA RESPONSE PROCESSING ******************//
        NSArray *uniqueIdentifiers = [self.dataResponseProcessors[relationship.destinationEntity.name] uniqueIdentifiersForEntity:relationship.destinationEntity responseData:serviceData error:&serviceError];
        
        NSString *identifier = uniqueIdentifiers.firstObject;
        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        if (serviceError != nil && error != NULL) {
            *error = serviceError;
            return nil;
        }
        
        if (identifier == nil) {
            // TODO: Report Error;
            return nil;
        }

        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////

        //****************** END DATA RESPONSE PROCESSING ******************//

        
        //****************** BEGIN OBJECT ID PROCESSING ******************//
        NSManagedObjectID *relationshipObjectID = [self newObjectIDForEntity:relationship.destinationEntity referenceObject:identifier];
        
        return relationshipObjectID;
        //****************** END OBJECT ID PROCESSING ******************//

    }
    
    return nil;
}

//TODO: Is this needed?
- (NSArray<NSManagedObjectID *> *)obtainPermanentIDsForObjects:(NSArray<NSManagedObject *> *)array
                                                         error:(NSError * _Nullable *)error {
    NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSManagedObject *managedObject in array) {
        NSManagedObjectID *objectID = [self newObjectIDForEntity:managedObject.entity referenceObject:[NSUUID new].UUIDString];
        [objectIDs addObject:objectID];
    }
    
    return objectIDs;
    
}

//TODO: Is this needed?
+ (id)identifierForNewStoreAtURL:(NSURL *)storeURL {
    return nil;
}

- (void)managedObjectContextDidRegisterObjectsWithIDs:(NSArray<NSManagedObjectID *> *)objectIDs {
    for (NSManagedObjectID *objectID in objectIDs) {
        [self.rowCache incrementReferenceCountForObjectID:objectID];
    }
    return;
}

- (void)managedObjectContextDidUnregisterObjectsWithIDs:(NSArray<NSManagedObjectID *> *)objectIDs {
    for (NSManagedObjectID *objectID in objectIDs) {
        [self.rowCache decrementReferenceCountForObjectID:objectID];
    }
}


#pragma mark - Extended Methods

- (NSDate *)lastUpdateForServiceURL:(NSURL *)serviceURL forRequestingEntity:(NSEntityDescription *)entity withContext:(NSManagedObjectContext *)context {
    //****************** BEGIN LAST UPDATE PROCESSING ******************//
    NSURLRequest *serviceRequest = [self serviceRequestForServiceURL:serviceURL
                                                 forRequestingEntity:entity
                                                         forceReload:NO];
    NSCachedURLResponse *cachedResponse = [self cachedResponseForServiceRequest:serviceRequest
                                                            forRequestingEntity:entity
                                                                    withContext:context];
    NSDictionary *headers = ((NSHTTPURLResponse *)cachedResponse.response).allHeaderFields;
    NSString *cachedResponseDateString = headers[@"Date"];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (cachedResponseDateString == nil) { return nil; }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    
    NSDateFormatter *cachedResponseDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [cachedResponseDateFormatter setLocale:locale];
    [cachedResponseDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [cachedResponseDateFormatter setDateFormat:@"EEE', 'dd' 'MMM' 'yyyy' 'HH':'mm':'ss' 'zzz"];
    NSDate *cachedResponseDate = [cachedResponseDateFormatter dateFromString:cachedResponseDateString];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (cachedResponseDate == nil) { return nil; }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    return cachedResponseDate;
    
    //****************** END LAST UPDATE PROCESSING ******************//
}

- (NSData *)responseDataForServiceURL:(NSURL *)serviceURL
                     forRequestingEntity:(NSEntityDescription *)entity
                          withContext:(NSManagedObjectContext *)context
                          lastUpdate:(NSDate *)lastUpdate
                          forceReload:(BOOL)reload
                                error:(NSError * _Nullable *)error {
    
    //****************** BEGIN DATA REQUEST PROCESSING ******************//
    NSURLRequest *serviceRequest = [self serviceRequestForServiceURL:serviceURL forRequestingEntity:entity forceReload:reload];

    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (serviceRequest == nil) { return nil; }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    NSCachedURLResponse *cachedResponse = [self cachedResponseForServiceRequest:serviceRequest
                                                               forRequestingEntity:entity
                                                                    withContext:context];
    
    NSURLRequestCachePolicy cachePolicy = serviceRequest.cachePolicy;

    if (cachePolicy == NSURLRequestReturnCacheDataDontLoad) {
        return cachedResponse != nil ? cachedResponse.data : nil;
        
    } else if (cachePolicy == NSURLRequestReloadIgnoringCacheData ||
               cachePolicy == NSURLRequestReloadIgnoringLocalCacheData ||
               cachePolicy == NSURLRequestReloadIgnoringLocalAndRemoteCacheData) {
        return [self responseForServiceRequest:serviceRequest lastUpdate:lastUpdate error:error];
        
    } else if (cachePolicy == NSURLRequestReturnCacheDataElseLoad ||
               cachePolicy == NSURLRequestReloadRevalidatingCacheData) {
        return cachedResponse != nil && cachedResponse.data != nil ? cachedResponse.data : [self responseForServiceRequest:serviceRequest lastUpdate:lastUpdate error:error];
    }
    return nil;
    
    //****************** END DATA REQUEST PROCESSING ******************//

}

- (NSURLRequest *)serviceRequestForServiceURL:(NSURL *)URL
                             forRequestingEntity:(NSEntityDescription *)entity
                                  forceReload:(BOOL)reload {
    
    //****************** BEGIN CACHE REQUEST PROCESSING ******************//
    NSTimeInterval serviceRequestTimeout = self.dataRequestSession.configuration.timeoutIntervalForRequest;
    NSNumber *entityTimeout = entity.userInfo[@"requestTimeoutInterval"];
    if (entityTimeout != nil) { serviceRequestTimeout = entityTimeout.doubleValue; }
    
    NSString *ignoreCacheString = (NSString *)entity.userInfo[@"ignoreCache"];
    NSURLRequestCachePolicy cachePolicy;
    if (reload == YES) {
        cachePolicy = NSURLRequestReloadIgnoringCacheData;
    } else if (ignoreCacheString != nil) {
        BOOL ignoreCache = ((NSString *)entity.userInfo[@"ignoreCache"]).boolValue;
        cachePolicy = ignoreCache == YES ? NSURLRequestReloadIgnoringCacheData : NSURLRequestReturnCacheDataElseLoad;
    } else {
        cachePolicy = self.dataRequestSession.configuration.requestCachePolicy;
    }
    
    NSURLRequest *serviceRequest = [NSURLRequest requestWithURL:URL
                                                    cachePolicy:cachePolicy
                                                timeoutInterval:serviceRequestTimeout];
    
    return serviceRequest;
    
    //****************** END CACHE REQUEST PROCESSING ******************//

}

- (NSCachedURLResponse *)cachedResponseForServiceRequest:(NSURLRequest *)serviceRequest
                                        forRequestingEntity:(NSEntityDescription *)entity
                                             withContext:(NSManagedObjectContext *)context {
    
    //****************** BEGIN CACHE REQUEST PROCESSING ******************//

    NSCachedURLResponse *cachedResponse = [self.dataCache cachedResponseForRequest:serviceRequest];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////

    if (cachedResponse == nil) { return nil; }
    
    if ([cachedResponse.response isKindOfClass: [NSHTTPURLResponse class]] == NO) { return nil; }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    NSString *cacheExpirationIntervalString = entity.userInfo[@"cacheExpirationInterval"];
    NSTimeInterval cacheExpirationInterval = cacheExpirationIntervalString != nil ? [cacheExpirationIntervalString doubleValue] : self.dataCacheExpirationInterval;
    cacheExpirationInterval = fabs(cacheExpirationInterval) * -1.0;
    NSDate *cacheExpirationDate = [NSDate dateWithTimeIntervalSinceNow:cacheExpirationInterval];
    
    NSDictionary *headers = ((NSHTTPURLResponse *)cachedResponse.response).allHeaderFields;
    NSString *cachedResponseDateString = headers[@"Date"];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (cachedResponseDateString == nil) { return nil; }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    
    NSDateFormatter *cachedResponseDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [cachedResponseDateFormatter setLocale:locale];
    [cachedResponseDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [cachedResponseDateFormatter setDateFormat:@"EEE', 'dd' 'MMM' 'yyyy' 'HH':'mm':'ss' 'zzz"];
    NSDate *cachedResponseDate = [cachedResponseDateFormatter dateFromString:cachedResponseDateString];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (cachedResponseDate == nil) { return nil; }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    NSComparisonResult result = [cacheExpirationDate compare:cachedResponseDate];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (result == NSOrderedDescending) {
        [self.dataCache removeCachedResponseForRequest:serviceRequest];
        return nil;
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    return cachedResponse;
    
    //****************** END CACHE REQUEST PROCESSING ******************//

}

- (NSData *)responseForServiceRequest:(NSURLRequest *)serviceRequest
                          lastUpdate:(NSDate *)lastUpdate
                                error:(NSError * _Nullable *)error {
    
    //****************** BEGIN DATA REQUEST PROCESSING ******************//
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSData * __block serviceData = nil;
    NSURLResponse * __block serviceResponse = nil;
    NSError * __block serviceError = nil;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSURLSessionDataTask *task = [self.dataRequestSession dataTaskWithRequest:serviceRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            //////////////////////////////////////////////////////
            ///////////////////// CHECKPOINT /////////////////////
            //////////////////////////////////////////////////////
            
            if (error != nil) {
                serviceError = error;
                dispatch_semaphore_signal(sema);
                return;
            }
            
            /////////////////////////////////////////////////////
            //////////////////////////////////////////////////////
            //////////////////////////////////////////////////////
            
            serviceData = data;
            serviceResponse = response;
            dispatch_semaphore_signal(sema);
            
        }];
        [task resume];
        
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (serviceError != nil && error != NULL) {
            *error = serviceError;
            return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END DATA REQUEST PROCESSING ******************//
    
    
    //****************** BEGIN DATA RESPONSE PROCESSING ******************//

    NSHTTPURLResponse *httpResponse = nil;
    
    if ([serviceResponse isKindOfClass:[NSHTTPURLResponse class]] == YES ) {
        httpResponse = (NSHTTPURLResponse *)serviceResponse;
        NSMutableDictionary *headerDictionary = [NSMutableDictionary dictionaryWithDictionary:httpResponse.allHeaderFields];
        if (httpResponse.allHeaderFields[@"Last-Modified"] == nil) {
            NSDate *lastModified = lastUpdate != nil ? lastUpdate : [NSDate date];
            [headerDictionary setObject:[NSISO8601DateFormatter stringFromDate:lastModified
                                                                      timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0] formatOptions:NSISO8601DateFormatWithInternetDateTime] forKey:@"Last-Modified"];
            httpResponse = [[NSHTTPURLResponse alloc] initWithURL:httpResponse.URL
                                                       statusCode:httpResponse.statusCode
                                                      HTTPVersion:@"HTTP/1.1" // TODO: Is there a way to read this?
                                                     headerFields:headerDictionary];
        }
        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:httpResponse
                                                                                       data:serviceData
                                                                                   userInfo:nil // TODO: MAYBE ENABLE THIS?
                                                                              storagePolicy:NSURLCacheStorageAllowed];
        [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse
                                              forRequest:serviceRequest];
        
    } // TODO: WHAT IF IT'S NOT HTTP?
    
    return serviceData;
    
    //****************** END DATA RESPONSE PROCESSING ******************//

}


@end


