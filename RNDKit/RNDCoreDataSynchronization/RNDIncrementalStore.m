//
//  RNDIncrementalStore.m
//  RNDKit
//
//  Created by Erikheath Thomas on 4/26/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDIncrementalStore.h"
#import "RNDJSONResponseProcessor.h"

@interface RNDIncrementalStore()

@property (strong, nonnull, nonatomic, readonly) NSMutableDictionary *semaphoreDictionary;
@property (strong, nonnull, nonatomic, readonly) dispatch_queue_t semaphoreQueue;
@property (strong, nonnull, nonatomic, readonly) dispatch_queue_t errorQueue;

@end

@implementation RNDIncrementalStore


#pragma mark - Property Definitions

@synthesize semaphoreDictionary = _semaphoreDictionary;
@synthesize semaphoreQueue = _semaphoreQueue;
@synthesize errorQueue = _errorQueue;
@synthesize rowCache = _rowCache;
@synthesize dataRequestDelegateQueue = _dataRequestDelegateQueue;
@synthesize dataResponseProcessors = _dataResponseProcessors;

// TODO: WRITE BARRIERS AROUND RW PROPERTIES

#pragma mark - Core Data Override Definitions

- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)root configurationName:(NSString *)name URL:(NSURL *)url options:(NSDictionary *)options {
    if ((self = [super initWithPersistentStoreCoordinator:root
                                        configurationName:name
                                                      URL:url
                                                  options:options]) != nil) {
        _semaphoreDictionary = [NSMutableDictionary dictionary];
        
        _semaphoreQueue = dispatch_queue_create("semaphoreQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL, QOS_CLASS_DEFAULT, QOS_MIN_RELATIVE_PRIORITY));
        
        _errorQueue = dispatch_queue_create("errorQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL, QOS_CLASS_USER_INITIATED, QOS_MIN_RELATIVE_PRIORITY));
        
        _rowCache = [RNDRowCache new];
        
        _dataCache = [NSURLCache sharedURLCache];
        
        _dataRequestDelegateQueue = [[NSOperationQueue alloc] init];
        
        _dataRequestSession = [NSURLSession sessionWithConfiguration:self.dataRequestConfigfuration delegate:self.dataRequestDelegate delegateQueue:self.dataRequestDelegateQueue];
        
        _dataRequestConfigfuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _dataRequestConfigfuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        _dataResponseProcessors = [NSMutableDictionary new];
        
        _dataRequestQueryItemPredicateParser = [RNDQueryItemPredicateParser new];
        
    }
    
    return self;
}

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
                                          withLoadingPriority:QOS_CLASS_USER_INITIATED
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
        
        NSInteger backgroundPrefetchLimit = MAX(0,((NSString *)entity.userInfo[@"backgroundPrefetchLimit"]).integerValue);
        NSInteger backgroundPreloadLimit = MAX(0,((NSString *)entity.userInfo[@"backgroundPreloadLimit"]).integerValue);
        NSInteger priorityPreloadLimit = MAX(0,((NSString *)entity.userInfo[@"priorityPreloadLimit"]).integerValue);
        
        if (backgroundPrefetchLimit == 0 &&
            backgroundPreloadLimit == 0 &&
            priorityPreloadLimit == 0) {
            return fetchedObjects;
        }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        
        //****************** END RESPONSE DATA PROCESSING ******************//
        
        
        //****************** BEGIN PREFETCH/PRELOAD PROCESSING ******************//
        
        NSDictionary *lastUpdated = [self.dataResponseProcessors[entity.name] lastUpdatesForEntity:entity objectIDs:fetchedObjects responseData:serviceData error:&serviceError];
        
        NSMutableArray *errorArray = [NSMutableArray new];
        
        dispatch_group_t dispatchGroup = dispatch_group_create();
        
        NSMutableArray <NSNumber *> *queuePriorityArray = [NSMutableArray arrayWithCapacity:primaryKeys.count];
        NSInteger preloadCount = priorityPreloadLimit + backgroundPreloadLimit;
        
        for (NSInteger count = 0; count < priorityPreloadLimit && count < primaryKeys.count; count++) {
            [queuePriorityArray addObject:[NSNumber numberWithUnsignedInt:QOS_CLASS_USER_INITIATED]];
            
        }
        for (NSInteger count = queuePriorityArray.count; count < preloadCount && count < primaryKeys.count; count++) {
            [queuePriorityArray addObject:[NSNumber numberWithUnsignedInt:QOS_CLASS_DEFAULT]];
        }
        for (NSInteger count = queuePriorityArray.count; count < backgroundPrefetchLimit && count < primaryKeys.count; count++) {
            [queuePriorityArray addObject:[NSNumber numberWithUnsignedInt:QOS_CLASS_BACKGROUND]];
        }
        
        primaryKeys = [primaryKeys subarrayWithRange:NSMakeRange(0, queuePriorityArray.count)];
        
        [primaryKeys enumerateObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(id  _Nonnull primaryKey, NSUInteger idx, BOOL * _Nonnull stop) {
                                          
                                          NSManagedObjectID *objectID = fetchedObjects[idx];
                                          
                                          //////////////////////////////////////////////////////
                                          ///////////////////// CHECKPOINT /////////////////////
                                          //////////////////////////////////////////////////////
                                          
                                          dispatch_semaphore_t __block semaphore = nil;
                                          BOOL __block shouldExit = NO;
                                          
                                          dispatch_sync(self.semaphoreQueue, ^{
                                              if ([self.semaphoreDictionary objectForKey:@[primaryKey, entity.name]] != nil) {
                                                  shouldExit = YES;
                                                  return;
                                              }
                                              semaphore = dispatch_semaphore_create(0);
                                              [self.semaphoreDictionary setObject:semaphore forKey:@[primaryKey, entity.name]];
                                          });
                                          
                                          if (shouldExit == YES) { return; }
                                          
                                          /////////////////////////////////////////////////////
                                          //////////////////////////////////////////////////////
                                          //////////////////////////////////////////////////////
                                          
                                          qos_class_t serviceQuality = queuePriorityArray[idx].unsignedIntValue;
                                          dispatch_group_async(dispatchGroup, dispatch_get_global_queue(serviceQuality, 0), ^{
                                              NSError *prefetchError = nil;
                                              NSURL *serviceURL = [NSURL URLWithString:(NSString *)primaryKey];
                                              NSData *prefetchData = [self responseDataForServiceURL:serviceURL
                                                                                 forRequestingEntity:entity
                                                                                         withContext:context
                                                                                 withLoadingPriority:serviceQuality lastUpdate:lastUpdated[primaryKey]
                                                                                         forceReload:ignoreCache
                                                                                               error:&prefetchError];
                                              
                                              //////////////////////////////////////////////////////
                                              ///////////////////// CHECKPOINT /////////////////////
                                              //////////////////////////////////////////////////////
                                              
                                              if (prefetchError != nil) {
                                                  dispatch_sync(self.errorQueue, ^{
                                                      [errorArray addObject:prefetchError];
                                                  });
                                                  dispatch_sync(self.semaphoreQueue, ^{
                                                      dispatch_semaphore_t sema = self.semaphoreDictionary[@[primaryKey, entity.name]];
                                                      dispatch_semaphore_signal(sema);
                                                      [self.semaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
                                                  });
                                                  return;
                                              }
                                              
                                              if (prefetchData == nil) {
                                                  // TODO: return Error
                                                  dispatch_sync(self.semaphoreQueue, ^{
                                                      dispatch_semaphore_t sema = self.semaphoreDictionary[@[primaryKey, entity.name]];
                                                      dispatch_semaphore_signal(sema);
                                                      [self.semaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
                                                  });
                                                  return;
                                              }
                                              
                                              if (idx >= preloadCount) {
                                                  dispatch_sync(self.semaphoreQueue, ^{
                                                      dispatch_semaphore_t sema = self.semaphoreDictionary[@[primaryKey, entity.name]];
                                                      dispatch_semaphore_signal(sema);
                                                      [self.semaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
                                                  });
                                                  return;
                                              }
                                              
                                              /////////////////////////////////////////////////////
                                              //////////////////////////////////////////////////////
                                              //////////////////////////////////////////////////////
                                              
                                              NSError *preloadError = nil;
                                              NSIncrementalStoreNode *node = [self rowForPrimaryKey:primaryKey
                                                                                        forObjectID:objectID
                                                                                          forEntity:entity
                                                                                        withContext:context
                                                                              
                                                                                withLoadingPriority:QOS_CLASS_BACKGROUND                     error:&preloadError].node;
                                              
                                              //////////////////////////////////////////////////////
                                              ///////////////////// CHECKPOINT /////////////////////
                                              //////////////////////////////////////////////////////
                                              
                                              if (preloadError != nil) {
                                                  dispatch_sync(self.errorQueue, ^{
                                                      [errorArray addObject:preloadError];
                                                  });
                                                  dispatch_sync(self.semaphoreQueue, ^{
                                                      dispatch_semaphore_t sema = self.semaphoreDictionary[@[primaryKey, entity.name]];
                                                      dispatch_semaphore_signal(sema);
                                                      [self.semaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
                                                  });
                                                  return;
                                              }
                                              
                                              if (node == nil) {
                                                  // TODO: return Error
                                                  dispatch_sync(self.semaphoreQueue, ^{
                                                      dispatch_semaphore_t sema = self.semaphoreDictionary[@[primaryKey, entity.name]];
                                                      dispatch_semaphore_signal(sema);
                                                      [self.semaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
                                                  });
                                                  return;
                                              }
                                              
                                              /////////////////////////////////////////////////////
                                              //////////////////////////////////////////////////////
                                              //////////////////////////////////////////////////////
                                              
                                              dispatch_sync(self.semaphoreQueue, ^{
                                                  dispatch_semaphore_t sema = self.semaphoreDictionary[@[primaryKey, entity.name]];
                                                  dispatch_semaphore_signal(sema);
                                                  [self.semaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
                                              });
                                          });
                                          
                                      }];
        
        
        dispatch_group_notify(dispatchGroup, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
            // TODO: WRITE TO ERROR LOG / DISPATCH NOTIFICATION
            if (errorArray.count > 0) {
                NSLog(@"%@", errorArray);
            }
        });
        
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
         withLoadingPriority:(qos_class_t)loadingPriority
                       error:(NSError * _Nullable *)error {
    //****************** BEGIN EXISTING ROW PROCESSING ******************//
    // Check for an existing node. If it's valid, return it.
    // 1. Does it exist?
    // 2. Is it unexpired?
    // 3. Has the proxy store acquired newer info?
    // 4. Do I ignore the cache
    RNDRow *row = [self.rowCache rowForObjectID:@[primaryKey, entity.name]];
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
        [lastUpdate compare:row.lastUpdated] != NSOrderedDescending) {
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
                              withLoadingPriority:loadingPriority
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
    
    NSTimeInterval expirationInterval = context.stalenessInterval < 0 ? 84000 : context.stalenessInterval;
    NSString *expirationIntervalString = entity.userInfo[@"entityExpirationInterval"];
    if (expirationIntervalString != nil) { expirationInterval = expirationIntervalString.doubleValue; }
    
    if (row != nil) {
        node = row.node;
        [node updateWithValues:values
                       version:node.version + 1];
        [row updateRowExpiration:expirationInterval];
    } else {
        node = [[NSIncrementalStoreNode alloc] initWithObjectID:objectID withValues:values version:version];
        row = [[RNDRow alloc] initWithNode:node
                               lastUpdated:[self lastUpdateForServiceURL:serviceURL
                                                     forRequestingEntity:entity
                                                             withContext:context]
                        expirationInterval:expirationInterval];
        [self.rowCache addRow:row forObjectID:@[primaryKey, entity.name]];
    }
    
    return row;
    
    //****************** END ROW PROCESSING ******************//
}

- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                         withContext:(NSManagedObjectContext *)context
                                               error:(NSError * _Nullable *)error {
    
    NSString *primaryKey = [self referenceObjectForObjectID:objectID];
    NSEntityDescription *entity = [[context objectWithID:objectID] entity];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    dispatch_semaphore_t __block semaphore = nil;
    
    dispatch_sync(self.semaphoreQueue, ^{
        semaphore = [self.semaphoreDictionary objectForKey:@[primaryKey, entity.name]];
    });
    if (semaphore != nil) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    NSIncrementalStoreNode *node = [self rowForPrimaryKey:primaryKey
                                              forObjectID:objectID
                                                forEntity:entity
                                              withContext:context
                                      withLoadingPriority:QOS_CLASS_USER_INITIATED
                                                    error:error].node;
    if (semaphore != nil) {
        dispatch_semaphore_signal(semaphore);
    }
    return node;
    
}


- (id)newValueForRelationship:(NSRelationshipDescription *)relationship
              forObjectWithID:(NSManagedObjectID *)objectID
                  withContext:(NSManagedObjectContext *)context
                        error:(NSError * _Nullable *)error {
    
    
    if (relationship.isToMany) {
        //        return @[];
        
        //****************** BEGIN DATA REQUEST PROCESSING ******************//
        BOOL ignoreCache = ((NSString *)relationship.entity.userInfo[@"ignoreCache"]).boolValue;
        NSError *serviceError = nil;
        NSURL *serviceURL = [NSURL URLWithString:[self referenceObjectForObjectID:objectID]];
        NSData *serviceData = [self responseDataForServiceURL:serviceURL
                                          forRequestingEntity:relationship.entity
                                                  withContext:context
                                          withLoadingPriority:QOS_CLASS_USER_INITIATED
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
        //        return nil;
        
        //****************** BEGIN DATA REQUEST PROCESSING ******************//
        BOOL ignoreCache = ((NSString *)relationship.entity.userInfo[@"ignoreCache"]).boolValue;
        NSError *serviceError = nil;
        NSURL *serviceURL = [NSURL URLWithString:[self referenceObjectForObjectID:objectID]];
        NSData *serviceData = [self responseDataForServiceURL:serviceURL
                                          forRequestingEntity:relationship.entity
                                                  withContext:context
                                          withLoadingPriority:QOS_CLASS_USER_INITIATED
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
                  withLoadingPriority:(qos_class_t)loadingPriority
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
        return [self responseForServiceRequest:serviceRequest withLoadingPriority:loadingPriority lastUpdate:lastUpdate error:error];
        
    } else if (cachePolicy == NSURLRequestReturnCacheDataElseLoad ||
               cachePolicy == NSURLRequestReloadRevalidatingCacheData) {
        return cachedResponse != nil && cachedResponse.data != nil ? cachedResponse.data : [self responseForServiceRequest:serviceRequest withLoadingPriority:loadingPriority lastUpdate:lastUpdate error:error];
    } else {
        return [self responseForServiceRequest:serviceRequest withLoadingPriority:loadingPriority lastUpdate:lastUpdate error:error];
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
    
    if (cachedResponse == nil) {
        return nil;
        
    }
    
    if ([cachedResponse.response isKindOfClass: [NSHTTPURLResponse class]] == NO) { return nil; }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    NSString *cacheExpirationIntervalString = entity.userInfo[@"cacheExpirationInterval"];
    NSTimeInterval cacheExpirationInterval = cacheExpirationIntervalString != nil ? [cacheExpirationIntervalString doubleValue] : self.dataCacheExpirationInterval;
    cacheExpirationInterval = fabs(cacheExpirationInterval);
    
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
    cachedResponseDate = [cachedResponseDate dateByAddingTimeInterval:cacheExpirationInterval];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (cachedResponseDate == nil) { return nil; }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    NSComparisonResult result = [[NSDate date] compare:cachedResponseDate];
    
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
                  withLoadingPriority:(qos_class_t)loadingPriority
                           lastUpdate:(NSDate *)lastUpdate
                                error:(NSError * _Nullable *)error {
    
    //****************** BEGIN DATA REQUEST PROCESSING ******************//
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSData * __block serviceData = nil;
    NSURLResponse * __block serviceResponse = nil;
    NSError * __block serviceError = nil;
    
    dispatch_sync(dispatch_get_global_queue(loadingPriority, 0), ^{
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


