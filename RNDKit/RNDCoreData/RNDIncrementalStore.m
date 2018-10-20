//
//  RNDIncrementalStore.m
//  RNDKit
//
//  Created by Erikheath Thomas on 4/26/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDIncrementalStore.h"
#import "RNDRowCache.h"
#import "RNDQueryItemPredicateParser.h"
#import "RNDJSONResponseProcessor.h"
#import "NSString+RNDStringExtensions.h"

@interface RNDIncrementalStore()

@property (strong, nonnull, nonatomic, readonly) NSMutableDictionary *rowSemaphoreDictionary;
@property (strong, nonnull, nonatomic, readonly) NSCountedSet *rowSemaphoreCounter;
@property (strong, nonnull, nonatomic, readonly) dispatch_queue_t semaphoreQueue;
@property (strong, nonnull, nonatomic, readonly) dispatch_queue_t errorQueue;
@property (strong, nonnull, nonatomic, readonly) dispatch_queue_t serialQueue;

@end

@implementation RNDIncrementalStore


#pragma mark - Property Definitions

@synthesize rowSemaphoreDictionary = _rowSemaphoreDictionary;
@synthesize rowSemaphoreCounter = _rowSemaphoreCounter;
@synthesize semaphoreQueue = _semaphoreQueue;
@synthesize errorQueue = _errorQueue;
@synthesize rowCache = _rowCache;
@synthesize URLConstructionDelegateQueue = _URLConstructionDelegateQueue;
@synthesize dataResponseProcessors = _dataResponseProcessors;
@synthesize serialQueue = _serialQueue;

#pragma mark - Core Data Override Definitions

- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)root configurationName:(NSString *)name URL:(NSURL *)url options:(NSDictionary *)options {
    if ((self = [super initWithPersistentStoreCoordinator:root
                                        configurationName:name
                                                      URL:url
                                                  options:options]) != nil) {
        
        _rowSemaphoreDictionary = [NSMutableDictionary dictionary];
        
        _rowSemaphoreCounter = [NSCountedSet new];
        
        _semaphoreQueue = dispatch_queue_create("semaphoreQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL, QOS_CLASS_DEFAULT, QOS_MIN_RELATIVE_PRIORITY));
        
        _errorQueue = dispatch_queue_create("errorQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL, QOS_CLASS_USER_INITIATED, QOS_MIN_RELATIVE_PRIORITY));
        
        _rowCache = [RNDRowCache new];
        
        _dataCache = [NSURLCache sharedURLCache];
        
        _URLConstructionDelegateQueue = [[NSOperationQueue alloc] init];
        
        _priorityDataRequestConfigfuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _priorityDataRequestConfigfuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        _priorityDataRequestSession = [NSURLSession sessionWithConfiguration:self.priorityDataRequestConfigfuration delegate:self.dataDelegate delegateQueue:self.dataDelegateQueue];
        
        _backgroundDataRequestConfigfuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _backgroundDataRequestConfigfuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        
        _backgroundDataRequestSession = [NSURLSession sessionWithConfiguration:_backgroundDataRequestConfigfuration delegate:self.dataDelegate delegateQueue:self.dataDelegateQueue];
        
        _dataResponseProcessors = [NSMutableDictionary new];
        
        _dataRequestQueryItemPredicateParser = [RNDQueryItemPredicateParser new];
        
        _serialQueue = dispatch_queue_create("serialQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL, QOS_CLASS_USER_INITIATED, QOS_MIN_RELATIVE_PRIORITY));
        
    }
    
    return self;
}

- (BOOL)loadMetadata:(NSError *__autoreleasing *)error {
    
    //****************** BEGIN STANDARD METADATA SETUP ******************//
    NSMutableDictionary *mutableMetadata = [NSMutableDictionary dictionary];
    [mutableMetadata setValue:[[NSProcessInfo processInfo] globallyUniqueString] forKey:NSStoreUUIDKey];
    [mutableMetadata setValue:NSStringFromClass([self class]) forKey:NSStoreTypeKey];
    [self setMetadata:mutableMetadata];
    //****************** END STANDARD METADATA SETUP ******************//
    
    
    //****************** BEGIN TEMPORARY CONFIGURATION SETUP ******************//
    //TODO: EXTERNAL CONFIGURATION FROM MODEL
    [self.dataResponseProcessors setObject:[RNDJSONResponseProcessor new] forKey:@"UNSListing"];
    [self.dataResponseProcessors setObject:[RNDJSONResponseProcessor new] forKey:@"UNSImage"];
    [self.dataResponseProcessors setObject:[RNDJSONResponseProcessor new] forKey:@"UNSProperty"];
    self.dataCacheExpirationInterval = 300;
    //****************** END TEMPORARY CONFIGURATION SETUP ******************//
    
    return YES;
}

- (id)executeRequest:(NSPersistentStoreRequest *)request
         withContext:(NSManagedObjectContext *)context
               error:(NSError * _Nullable *)error {
    
    if ([request requestType] == NSFetchRequestType) {
        NSFetchRequest *fetchRequest = (NSFetchRequest *)request;
        //****************** BEGIN FETCH REQUEST ROUTING ******************//
        if ([fetchRequest resultType] == NSManagedObjectIDResultType) {
            return [self managedObjectIDsForFetchRequest:fetchRequest
                                             withContext:context
                                                   error:error];
        } else if ([fetchRequest resultType] == NSManagedObjectResultType) {
            return [self managedObjectsForFetchRequest:fetchRequest
                                           withContext:context
                                                 error:error];
        } else if ([fetchRequest resultType] == NSCountResultType) {
            
        } else if ([fetchRequest resultType] == NSDictionaryResultType) {
            
        }
        //****************** END FETCH REQUEST ROUTING ******************//
    } else if ([request requestType] == NSSaveRequestType) {
        NSSaveChangesRequest *saveRequest = (NSSaveChangesRequest *)request;
        
        NSSet *insertedObjects = [saveRequest insertedObjects];
        if (insertedObjects != nil && insertedObjects.count > 0) {
            [self insertObjects:insertedObjects
                    withContext:context
                          error:error];
        }
        
        NSSet *updatedObjects = [saveRequest updatedObjects];
        if (updatedObjects != nil && updatedObjects.count > 0) {
            [self updateObjects:updatedObjects
                    withContext:context
                          error:error];
        }
        
        NSSet *deletedObjects = [saveRequest deletedObjects];
        if (deletedObjects != nil && deletedObjects.count > 0) {
            [self deleteObjects:updatedObjects
                    withContext:context
                          error:error];
        }
        
        NSSet *optLockObjects = [saveRequest lockedObjects];
        
        return @[];

    } else if ([request requestType] == NSBatchDeleteRequestType) {
        
    } else if ([request requestType] == NSBatchUpdateRequestType) {
        
    }
    
    return nil;
}

- (id)countForManagedObjectsForFetchRequest:(NSFetchRequest *)fetchRequest
                                withContext:(NSManagedObjectContext *)context
                                      error:(NSError * _Nullable *)error {
    return nil;
}

- (id)managedObjectIDsForFetchRequest:(NSFetchRequest *)fetchRequest
                        withContext:(NSManagedObjectContext *)context
                              error:(NSError * _Nullable *)error {
    return nil;
}

- (id)managedObjectsForFetchRequest:(NSFetchRequest *)fetchRequest
                        withContext:(NSManagedObjectContext *)context
                              error:(NSError * _Nullable *)error {
    
    if ([fetchRequest.predicate isKindOfClass:[NSComparisonPredicate class]] == YES && [(NSComparisonPredicate *)fetchRequest.predicate predicateOperatorType] == NSInPredicateOperatorType) {
        NSComparisonPredicate *predicate = (NSComparisonPredicate *)fetchRequest.predicate;
        NSSet *managedObjects = [[predicate rightExpression] expressionValueWithObject:nil context:nil];
        if (managedObjects == nil) { return nil; }
        NSMutableArray <NSManagedObject *> *fetchedObjects = [NSMutableArray new];
        for (NSManagedObject *object in managedObjects) {
            
            [fetchedObjects addObject:[context objectWithID:object.objectID]];
        }
        return fetchedObjects;
    } else {
        
        //****************** BEGIN FETCH REQUEST PROCESSING SETUP ******************//
        NSEntityDescription *entity = [fetchRequest entity];
        NSURL *serviceURL = nil;
        NSString *serviceURLString = nil;
        NSURLComponents *serviceComponents = nil;
        //****************** END FETCH REQUEST PROCESSING SETUP ******************//
        
        //****************** BEGIN DELEGATE URL PROCESSING ******************//
        if (self.URLConstructionDelegate != nil) {
            if ([self.URLConstructionDelegate respondsToSelector:@selector(storeShouldDelegateURLComponentConstructionForRequest:)] == YES && [self.URLConstructionDelegate storeShouldDelegateURLComponentConstructionForRequest:fetchRequest] == YES) {
                serviceComponents = [self.URLConstructionDelegate URLComponentsForRequest:fetchRequest];
            } else if ([self.URLConstructionDelegate respondsToSelector:@selector(storeShouldDelegateURLTemplateConstructionForRequest:)] == YES && [self.URLConstructionDelegate storeShouldDelegateURLTemplateConstructionForRequest:fetchRequest] == YES) {
                serviceURLString = [self.URLConstructionDelegate URLTempateForRequest:fetchRequest];
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
        if (serviceURLString != nil) {
            if (self.URLConstructionDelegate != nil && [self.URLConstructionDelegate respondsToSelector:@selector(storeShouldSubstituteVariablesForRequest:)] == YES && [self.URLConstructionDelegate storeShouldSubstituteVariablesForRequest:fetchRequest] == YES) {
                NSDictionary *substitutionDictionary = [self.URLConstructionDelegate substitutionDictionaryForRequest:fetchRequest defaultSubstitutions:@{}];
                for (NSString *variableName in substitutionDictionary) {
                    serviceURLString = [serviceURLString stringByReplacingOccurrencesOfString:variableName
                                                                                   withString:substitutionDictionary[variableName]];
                }
            }
        } else if (entity.userInfo[@"definesSubstitutions"] != nil) {
            NSArray *substitutionKeys = [entity.userInfo[@"definedSubstitutions"] componentsSeparatedByString:@","];
            NSMutableDictionary *substitutionDictionary = [NSMutableDictionary new];
            for (NSString *key in substitutionKeys) {
                NSString *value;
                if ((value = entity.userInfo[key]) == nil) { continue; }
                NSArray *testValuePairs = [value componentsSeparatedByString:@","];
                for (NSString *pair in testValuePairs) {
                    NSArray *testPair = [pair componentsSeparatedByString:@":"];
                    NSPredicate *test = [NSPredicate predicateWithFormat:testPair.firstObject];
                    if ([test evaluateWithObject:fetchRequest] == NO) { continue; }
                    [substitutionDictionary setObject:testPair[1] forKey:key];
                    break;
                }
            }
            for (NSString *variableName in substitutionDictionary) {
                serviceURLString = [serviceURLString stringByReplacingOccurrencesOfString:variableName
                                                                               withString:substitutionDictionary[variableName]];
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
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        
        NSMutableArray *transformedQueryItems = [NSMutableArray arrayWithCapacity:serviceComponents.queryItems.count];
        
        for (NSURLQueryItem *item in serviceComponents.queryItems) {
            NSString *name = nil;
            NSString *value = nil;
            NSAttributeDescription *attribute = entity.attributesByName[item.name];
            
            if (attribute == nil) {
                [transformedQueryItems addObject:[NSURLQueryItem queryItemWithName:item.name value:item.value]];
                continue;
            }
            
            NSString *serviceNameTransformerName = attribute.userInfo[@"serviceNameTransformer"];
            NSValueTransformer *serviceNameTransformer = serviceNameTransformerName != nil ? [NSValueTransformer valueTransformerForName:serviceNameTransformerName] : nil;
            name = serviceNameTransformer != nil ? [serviceNameTransformer transformedValue:item.name] : (serviceNameTransformerName != nil ? serviceNameTransformerName : item.name);
            
            NSString *serviceValueTransformerName = attribute.userInfo[@"serviceValueTransformer"];
            NSValueTransformer *serviceValueTransformer = serviceValueTransformerName != nil ? [NSValueTransformer valueTransformerForName:serviceValueTransformerName] : nil;
            value = serviceValueTransformer != nil ? [serviceValueTransformer transformedValue:item.value] : (serviceValueTransformerName != nil ? serviceValueTransformerName : item.value);
            
            [transformedQueryItems addObject:[NSURLQueryItem queryItemWithName:name value:value]];
        }
        
        for (NSURLQueryItem *item in transformedQueryItems) {
            if ([item.name isEqualToString:@"processor"] == NO) { continue; }
            if ([item.value isEqualToString:@"searchByPayment"] == NO) { continue; }
            
            NSUInteger downPaymentIndex = [transformedQueryItems indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[obj name] isEqualToString:@"downPayment"]) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            id downPayment = downPaymentIndex != NSNotFound ? transformedQueryItems[downPaymentIndex] : nil;
            
            NSUInteger monthlyPaymentIndex = [transformedQueryItems indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([[obj name] isEqualToString:@"monthlyPayment"]) {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }];
            id monthlyPayment = monthlyPaymentIndex != NSNotFound ? transformedQueryItems[monthlyPaymentIndex] : nil;
            
            if (downPayment == nil || monthlyPayment == nil) { break; } // TODO: Add an error??
            
            // Monthly payment * 12 * 30 == Total Payments
            // Total Payments - Total Interest + downpayment == maximum house price
            double payment = [[monthlyPayment value] doubleValue];
            double down = [[downPayment value] doubleValue];
            double rate = (5.5 / 12) /100;
            int number = 12 * 30;
            double principal = payment * ((pow((1 + rate), number) - 1) / (rate * pow((1 + rate), number)));
            double maximumPrice = principal + (down * 2);
            long roundedPrice = (round(maximumPrice)) / 1;
            [transformedQueryItems addObject:[NSURLQueryItem queryItemWithName:@"maxListPrice" value:[NSString stringWithFormat:@"%ld", roundedPrice]]];
            [transformedQueryItems removeObject:monthlyPayment];
            [transformedQueryItems removeObject:downPayment];
            [transformedQueryItems removeObject:item];
            break;
        }
        
        // TODO: Check
        // Make sure the URL and the search object are using the right set of values.
        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        [serviceComponents setQueryItems: transformedQueryItems];
        serviceURL = [serviceComponents URL];
        if (serviceURL == nil) { return nil; }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        
        //****************** END QUERY ITEM PROCESSING ******************//
        
        
        //****************** BEGIN OBJECT MATERIALIZATION ******************//
        
        //////////////////////////////////////////////////////
        ///////////////////// CHECKPOINT /////////////////////
        //////////////////////////////////////////////////////
        
        if ([entity.userInfo[@"materializationType"] isEqualToString:@"USE_PREDICATE_VALUES"]) {
            NSMutableDictionary *propertyDictionary = [NSMutableDictionary dictionaryWithCapacity:queryItems.count];
            for (NSURLQueryItem *keyValue in queryItems) {
                [propertyDictionary setObject:keyValue.value forKey:keyValue.name];
            }
            NSManagedObjectID *objectID = [self newObjectIDForEntity:entity
                                                     referenceObject:[[serviceComponents URL] absoluteString]];
            NSIncrementalStoreNode *node = [[NSIncrementalStoreNode alloc] initWithObjectID:objectID
                                                                                 withValues:propertyDictionary
                                                                                    version:1];
            RNDRow *row = [[RNDRow alloc] initWithNode:node
                                           lastUpdated:[NSDate date]
                                    expirationInterval:800000
                                            primaryKey:[[serviceComponents URL] absoluteString]
                                            entityName:entity.name];
            [self.rowCache addRow:row];
            return @[[context objectWithID:objectID]];
        }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        
        
        //****************** END OBJECT MATERIALIZATION ******************//
        
        
        //****************** BEGIN REQUEST DATA PROCESSING ******************//
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
        
        if (serviceError != nil) {
            if (error != NULL) {
                *error = serviceError;
            }
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
        
        if (dataProcessorError != nil) {
            if (error != NULL) {
                *error = dataProcessorError;
            }
            return nil;
        }
        
        if (primaryKeys.count == 0) {
            return @[];
        }
        
        /////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        //////////////////////////////////////////////////////
        
        NSMutableArray *fetchedObjects = [NSMutableArray arrayWithCapacity:[primaryKeys count]];
        NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:[primaryKeys count]];
        
        for (NSString *primaryKey in primaryKeys) {
            NSManagedObjectID *objectID = [self newObjectIDForEntity:entity referenceObject:primaryKey];
            [objectIDs addObject:objectID];
            NSManagedObject *managedObject = [context objectWithID:objectID];
            [fetchedObjects addObject:managedObject];
        }
        
        [self preloadDataForFetchRequest:fetchRequest
                                 context:context
                             primaryKeys:primaryKeys
                          fetchedObjects:fetchedObjects
                               objectIDs:objectIDs];
        return fetchedObjects;
        
        //****************** END RESPONSE DATA PROCESSING ******************//
        
    }
    return nil;
}

- (void)preloadDataForFetchRequest:(NSFetchRequest *)fetchRequest
                           context:(NSManagedObjectContext *)context
                       primaryKeys:(NSArray <NSString *> *)primaryKeys
                    fetchedObjects:(NSArray<NSManagedObject *> *)fetchedObjects
                         objectIDs:(NSArray<NSManagedObjectID *> *)objectIDs {

    NSEntityDescription *entity = fetchRequest.entity;
    
    NSInteger backgroundPrefetchLimit = MAX(0,((NSString *)entity.userInfo[@"backgroundPrefetchLimit"]).integerValue);
    NSInteger backgroundPreloadLimit = MAX(0,((NSString *)entity.userInfo[@"backgroundPreloadLimit"]).integerValue);
    NSInteger priorityPreloadLimit = MAX(0,((NSString *)entity.userInfo[@"priorityPreloadLimit"]).integerValue);
    
    if (backgroundPrefetchLimit == 0 &&
        backgroundPreloadLimit == 0 &&
        priorityPreloadLimit == 0) {
        return ;
    }

    
    //****************** BEGIN PRELOAD PROCESSING ******************//
    NSMutableArray *errorArray = [NSMutableArray new];
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
    
    dispatch_group_t dispatch_group = dispatch_group_create();
    
    dispatch_group_async(dispatch_group, dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        
        [primaryKeys enumerateObjectsWithOptions:NSEnumerationConcurrent
                                      usingBlock:^(id  _Nonnull primaryKey, NSUInteger idx, BOOL * _Nonnull stop) {
                                          
                                          NSManagedObjectID *objectID = objectIDs[idx];
                                          qos_class_t serviceQuality = queuePriorityArray[idx].unsignedIntValue;
                                          NSError *preloadError = nil;
                                          
                                          NSIncrementalStoreNode *node = [self rowForPrimaryKey:primaryKey
                                                                                    forObjectID:objectID
                                                                                      forEntity:entity
                                                                                    withContext:context
                                                                          
                                                                            withLoadingPriority:serviceQuality                     error:&preloadError].node;
                                          
                                          //////////////////////////////////////////////////////
                                          ///////////////////// CHECKPOINT /////////////////////
                                          //////////////////////////////////////////////////////
                                          
                                          if (preloadError != nil) {
                                              dispatch_sync(self.errorQueue, ^{
                                                  [errorArray addObject:preloadError];
                                              });
                                              return;
                                          }
                                          
                                          if (node == nil) {
                                              return;
                                          }
                                          
                                          /////////////////////////////////////////////////////
                                          //////////////////////////////////////////////////////
                                          //////////////////////////////////////////////////////
                                          
                                          for (NSRelationshipDescription *relationship in entity.relationshipsByName.allValues) {
                                              
                                              if (((NSString *)relationship.userInfo[@"preloadRelationship"]).boolValue == YES) {
                                                  
                                                  NSArray *relationshipKeys = [self keysFulfillingRelationship:relationship
                                                                                                 forPrimaryKey:primaryKey forObjectID:objectID withContext:context withLoadingPriority:serviceQuality error:&preloadError];
                                                  
                                                  //////////////////////////////////////////////////////
                                                  ///////////////////// CHECKPOINT /////////////////////
                                                  //////////////////////////////////////////////////////
                                                  
                                                  if (preloadError != nil) {
                                                      dispatch_sync(self.errorQueue, ^{
                                                          [errorArray addObject:preloadError];
                                                      });
                                                      return;
                                                  }
                                                  
                                                  /////////////////////////////////////////////////////
                                                  //////////////////////////////////////////////////////
                                                  //////////////////////////////////////////////////////
                                                  
                                                  NSInteger rowLimit = ((NSString *)relationship.userInfo[@"priorityPreloadLimit"]).integerValue;
                                                  if (rowLimit < relationshipKeys.count) {
                                                      relationshipKeys = [relationshipKeys subarrayWithRange:NSMakeRange(0, rowLimit)];
                                                  }
                                                  
                                                  [self rowsFulfillingRelationship:relationship
                                                                   withPrimaryKeys:relationshipKeys
                                                                 forSourceObjectID:objectID
                                                                       withContext:context
                                                               withLoadingPriority:serviceQuality
                                                                             error:&preloadError];
                                                  
                                                  //////////////////////////////////////////////////////
                                                  ///////////////////// CHECKPOINT /////////////////////
                                                  //////////////////////////////////////////////////////
                                                  
                                                  if (preloadError != nil) {
                                                      dispatch_sync(self.errorQueue, ^{
                                                          [errorArray addObject:preloadError];
                                                      });
                                                      return;
                                                  }
                                                  
                                                  /////////////////////////////////////////////////////
                                                  //////////////////////////////////////////////////////
                                                  //////////////////////////////////////////////////////
                                                  
                                              }
                                          }
                                          
                                      }];
        
    });
    
    dispatch_group_notify(dispatch_group, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        if (errorArray.count > 0) { }
    });
    
    //****************** END PRELOAD PROCESSING ******************//
    
}

- (BOOL)insertObjects:(NSSet<NSManagedObject *> *)objects
          withContext:(NSManagedObjectContext *)context
                error:(NSError * _Nullable *)error {
    
    for (NSManagedObject *object in objects) {
        NSMutableDictionary *values = [NSMutableDictionary new];
        for (NSString *propertyName in object.entity.attributesByName) {
            id value = [object valueForKey:propertyName];
            if (value == nil) { continue; }
            [values setObject:[object valueForKey:propertyName] forKey:propertyName];
        }
        NSIncrementalStoreNode *node = [[NSIncrementalStoreNode alloc] initWithObjectID:object.objectID withValues:values version:1];
        RNDRow *row = [[RNDRow alloc] initWithNode:node
                                       lastUpdated:[NSDate date]
                                expirationInterval:0
                                        primaryKey:[self referenceObjectForObjectID:object.objectID]
                                        entityName:object.entity.name];
        [self.rowCache addRow:row];
    }
    
    return YES;
}

- (BOOL)updateObjects:(NSSet *)objects
          withContext:(NSManagedObjectContext *)context
                error:(NSError * _Nullable *)error {
    
    for (NSManagedObject *object in objects) {
        NSMutableDictionary *values = [NSMutableDictionary new];
        for (NSString *propertyName in object.entity.propertiesByName) {
            if ([object valueForKey:propertyName] == nil) { continue; }
            [values setObject:[object valueForKey:propertyName] forKey:propertyName];
        }
        RNDRow *row = [self.rowCache rowForObjectID:@[[self referenceObjectForObjectID:object.objectID], object.entity.name]];
        [row.node updateWithValues:values version:row.node.version + 1];
    }
    
    return YES;
}

- (BOOL)deleteObjects:(NSSet *)objects
          withContext:(NSManagedObjectContext *)context
                error:(NSError * _Nullable *)error {
    return YES;
}


- (RNDRow *)rowForPrimaryKey:(NSString *)primaryKey
                 forObjectID:(NSManagedObjectID *)objectID
                   forEntity:(NSEntityDescription *)entity
                 withContext:(NSManagedObjectContext *)context
         withLoadingPriority:(qos_class_t)loadingPriority
                       error:(NSError * _Nullable *)error {
    
    //****************** BEGIN SEMAPHORE COORDINATION SETUP ******************//
    dispatch_semaphore_t __block semaphore = nil;
    
    dispatch_sync(self.semaphoreQueue, ^{
        if ((semaphore = [self.rowSemaphoreDictionary objectForKey:@[primaryKey, entity.name]]) == nil) {
            semaphore = dispatch_semaphore_create(1);
            [self.rowSemaphoreDictionary setObject:semaphore forKey:@[primaryKey, entity.name]];
        }
        [self.rowSemaphoreCounter addObject:semaphore];
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    //****************** END SEMAPHORE COORDINATION SETUP ******************//
    
    
    //****************** BEGIN EXISTING ROW PROCESSING ******************//
    RNDRow *row = [self.rowCache rowForObjectID:@[primaryKey, entity.name]];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if ([entity.userInfo[@"PERSISTENCETYPE"] isEqualToString:@"IN_MEMORY"]) {
        dispatch_semaphore_signal(semaphore);
        return row;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    
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
        dispatch_semaphore_signal(semaphore);
        dispatch_async(self.semaphoreQueue, ^{
            [self.rowSemaphoreCounter removeObject:semaphore];
            if ([self.rowSemaphoreCounter countForObject:semaphore] == 0) {
                [self.rowSemaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
            }
        });
        return row;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END EXISTING ROW PROCESSING ******************//
    
    
    //this could be a new method is called either synchronously or async depending on the
    // setting in the entity.
    if ([entity.userInfo[@"requestType"] isEqualToString:@"ASYNC"]) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
           RNDRow *row = [self updatedRowForPrimaryKey:primaryKey
                            forObjectID:objectID
                              forEntity:entity
                            withContext:context
                    withLoadingPriority:loadingPriority
                            ignoreCache:ignoreCache
                             rowCounter:semaphore
                                  error:NULL];
            [[context persistentStoreCoordinator] performBlock:^{
                NSManagedObject *object = [context objectWithID:objectID];
                [context refreshObject:object mergeChanges:YES];
            }];
        });
        uint64_t version = row != nil ? row.node.version : 0; // NOTE: Should this be updated or should it wait until the data is returned to update? Maybe this should be a switch of some sort?
        NSIncrementalStoreNode *node = [[NSIncrementalStoreNode alloc] initWithObjectID:objectID withValues:@{} version:version]; // NOTE: As stated before, this should vary depending on whether a node exists or not. If an update, then the node should be updated instead of being recreated.
        return [[RNDRow alloc] initWithNode:node lastUpdated:[NSDate date] expirationInterval:0 primaryKey:primaryKey entityName:entity.name];
    } else {
        return [self updatedRowForPrimaryKey:primaryKey
                                 forObjectID:objectID
                                   forEntity:entity
                                 withContext:context
                         withLoadingPriority:loadingPriority
                                 ignoreCache:ignoreCache
                                  rowCounter:semaphore
                                       error:error];
    }
    
}

- (RNDRow *)updatedRowForPrimaryKey:(NSString *)primaryKey
                       forObjectID:(NSManagedObjectID *)objectID
                         forEntity:(NSEntityDescription *)entity
                       withContext:(NSManagedObjectContext *)context
               withLoadingPriority:(qos_class_t)loadingPriority
                       ignoreCache:(BOOL)ignoreCache
                        rowCounter:(dispatch_semaphore_t)semaphore
                             error:(NSError * _Nullable *)error {
    
    
    //****************** BEGIN DATA REQEUST PROCESSING ******************//
    NSData * __block serviceData = nil;
    NSError * __block serviceError = nil;
    NSURL *serviceURL = [NSURL URLWithString:primaryKey];
    
    serviceData = [self responseDataForServiceURL:serviceURL
                              forRequestingEntity:entity
                                      withContext:context
                              withLoadingPriority:loadingPriority
                                       lastUpdate:nil
                                      forceReload:ignoreCache
                                            error:&serviceError];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (serviceError != nil) {
        if (error != NULL) {
            *error = serviceError;
        }
        
        dispatch_semaphore_signal(semaphore);
        dispatch_async(self.semaphoreQueue, ^{
            [self.rowSemaphoreCounter removeObject:semaphore];
            if ([self.rowSemaphoreCounter countForObject:semaphore] == 0) {
                [self.rowSemaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
            }
        });
        
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
    
    if (serviceError != nil) {
        if (error != NULL) {
            *error = serviceError;
        }
        
        dispatch_semaphore_signal(semaphore);
        dispatch_async(self.semaphoreQueue, ^{
            [self.rowSemaphoreCounter removeObject:semaphore];
            if ([self.rowSemaphoreCounter countForObject:semaphore] == 0) {
                [self.rowSemaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
            }
        });
        
        return nil;
    }
    
    if (values == nil) {
        dispatch_semaphore_signal(semaphore);
        dispatch_async(self.semaphoreQueue, ^{
            [self.rowSemaphoreCounter removeObject:semaphore];
            if ([self.rowSemaphoreCounter countForObject:semaphore] == 0) {
                [self.rowSemaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
            }
        });
        
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END DATA RESPONSE PROCESSING ******************//
    
    
    //****************** BEGIN ROW PROCESSING ******************//
    RNDRow *row = nil;
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
                        expirationInterval:expirationInterval
                                primaryKey:primaryKey
                                entityName:entity.name];
        [self.rowCache addRow:row];
        
    }
    
    dispatch_semaphore_signal(semaphore);
    dispatch_async(self.semaphoreQueue, ^{
        [self.rowSemaphoreCounter removeObject:semaphore];
        if ([self.rowSemaphoreCounter countForObject:semaphore] == 0) {
            [self.rowSemaphoreDictionary removeObjectForKey:@[primaryKey, entity.name]];
        }
    });
    
    return row;
    //****************** END ROW PROCESSING ******************//
}

- (NSURL *)sourceURLForGeospatialRelationship:(NSRelationshipDescription *)relationship
                                forPrimaryKey:(NSString *)primaryKey
                                  withContext:(NSManagedObjectContext *)context
                   usingSubstitutionVariables:(NSDictionary *)substitutions
                                        error:(NSError * _Nullable *)error {
    //
    return nil;
}

- (NSURL *)sourceURLForRelationship:(NSRelationshipDescription *)relationship
                      forPrimaryKey:(NSString *)primaryKey
                        withContext:(NSManagedObjectContext *)context
         usingSubstitutionVariables:(NSDictionary *)substitutions
                              error:(NSError * _Nullable *)error {
    // This needs to vary based on the type of relationship -
    // to many, to one, geospatial, normal, etc.
    // Relationship Type: GEOSPATIAL,
    
    NSMutableDictionary *variables = [NSMutableDictionary dictionaryWithDictionary:substitutions];
    
    [variables setObject:primaryKey forKey:@"$SOURCEURL"];
    
    NSString *sourceURLString = nil;
    if ((sourceURLString = relationship.userInfo[@"destinationURL"]) != nil) {
        return [NSURL URLWithString:[sourceURLString stringWithSubstitutions:variables]];
    }
    
    NSURLComponents *urlComponents = [NSURLComponents new];
    urlComponents.host = [relationship.userInfo[@"host"] stringWithSubstitutions:variables];
    urlComponents.scheme = [relationship.userInfo[@"scheme"] stringWithSubstitutions:variables];
    urlComponents.path = [relationship.userInfo[@"path"] stringWithSubstitutions:variables];
    urlComponents.port = @([[relationship.userInfo[@"port"] stringWithSubstitutions:variables] longValue]);
    
    NSString *queryItems = relationship.userInfo[@"queryItems"];
    NSArray *queryItemStringArray = [queryItems componentsSeparatedByString:@","];
    NSMutableArray *queryItemArray = [NSMutableArray arrayWithCapacity:queryItemStringArray.count];
    RNDRow *row = [self.rowCache rowForObjectID:@[primaryKey, relationship.entity]];
    for (NSString *item in queryItemStringArray) {
        NSString *trimmedItem = [item stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        id value = [row.node valueForPropertyDescription:relationship.entity.propertiesByName[trimmedItem]];
        [queryItemArray addObject:[NSURLQueryItem queryItemWithName:trimmedItem
                                                              value:[[NSString stringWithFormat:@"%@", value] stringWithSubstitutions:variables]]];
    }
    urlComponents.queryItems = queryItemArray;
    
    return [urlComponents URL];
}


- (NSArray <NSString *> *)keysFulfillingRelationship:(NSRelationshipDescription *)relationship
                                       forPrimaryKey:(NSString *)primaryKey
                                         forObjectID:(NSManagedObjectID *)objectID
                                         withContext:(NSManagedObjectContext *)context
                                 withLoadingPriority:(qos_class_t)loadingPriority
                                               error:(NSError * _Nullable *)error {
    
    //****************** BEGIN DATA REQUEST PROCESSING ******************//
    // This is the point to replace the URL call with the new URL generator.
    //    NSURL *serviceURL = [NSURL URLWithString:primaryKey];
    NSError *serviceURLError = nil;
    NSURL *serviceURL = [self sourceURLForRelationship:relationship
                                         forPrimaryKey:primaryKey
                                           withContext:context
                            usingSubstitutionVariables:nil
                                                 error:&serviceURLError];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (serviceURLError != nil) {
        if (error != NULL) {
            *error = serviceURLError;
        }
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    BOOL ignoreCache = ((NSString *)relationship.entity.userInfo[@"ignoreCache"]).boolValue;
    NSError *serviceError = nil;
    
    NSData *serviceData = [self responseDataForServiceURL:serviceURL
                                      forRequestingEntity:relationship.entity
                                              withContext:context
                                      withLoadingPriority:loadingPriority
                                               lastUpdate:nil
                                              forceReload:ignoreCache
                                                    error:&serviceError];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (serviceError != nil) {
        if (error != NULL) {
            *error = serviceError;
        }
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END DATA REQUEST PROCESSING ******************//
    
    
    //****************** BEGIN RESPONSE DATA PROCESSING ******************//
    NSError *dataProcessorError = nil;
    NSArray *relationshipPrimaryKeys = [self.dataResponseProcessors[relationship.destinationEntity.name] uniqueIdentifiersForEntity:relationship.destinationEntity responseData:serviceData error:&dataProcessorError];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (dataProcessorError != nil) {
        if (error != NULL) {
            *error = dataProcessorError;
        }
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    return relationshipPrimaryKeys;
    //****************** END RESPONSE DATA PROCESSING ******************//
}

- (NSArray <RNDRow *> *)rowsFulfillingRelationship:(NSRelationshipDescription *)relationship
                                   withPrimaryKeys:(NSArray<NSString *> *)primaryKeys
                                 forSourceObjectID:(NSManagedObjectID *)objectID
                                       withContext:(NSManagedObjectContext *)context
                               withLoadingPriority:(qos_class_t)loadingPriority
                                             error:(NSError * _Nullable *)error {
    
    //****************** BEGIN ROW PROCESSING ******************//
    NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:primaryKeys.count];
    NSMutableArray *objectIDArray = [NSMutableArray arrayWithCapacity:primaryKeys.count];
    
    for (NSString *primaryKey in primaryKeys) {
        [objectIDArray addObject:[self newObjectIDForEntity:relationship.destinationEntity referenceObject:primaryKey]];
    }
    
    [primaryKeys enumerateObjectsWithOptions:NSEnumerationConcurrent
                                  usingBlock:^(id  _Nonnull primaryKey, NSUInteger idx, BOOL * _Nonnull stop) {
                                      NSError *rowError = nil;
                                      RNDRow *row = [self rowForPrimaryKey:primaryKey
                                                               forObjectID:objectIDArray[idx]
                                                                 forEntity:relationship.destinationEntity
                                                               withContext:context
                                                       withLoadingPriority:loadingPriority
                                                                     error:&rowError];
                                      dispatch_sync(self.serialQueue, ^{
                                          [rowArray addObject:row];
                                      });
                                  }];
    
    return [NSArray arrayWithArray:rowArray];
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
                                      withLoadingPriority:QOS_CLASS_USER_INITIATED
                                                    error:error].node;
    return node;
    
}


- (id)newValueForRelationship:(NSRelationshipDescription *)relationship
              forObjectWithID:(NSManagedObjectID *)objectID
                  withContext:(NSManagedObjectContext *)context
                        error:(NSError * _Nullable *)error {
    
    //****************** BEGIN PRIMARY KEY PROCESSING ******************//
    NSArray *primaryKeys = [self keysFulfillingRelationship:relationship
                                              forPrimaryKey:[self referenceObjectForObjectID:objectID]
                                                forObjectID:objectID
                                                withContext:context
                                        withLoadingPriority:QOS_CLASS_USER_INITIATED
                                                      error:error];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (error != NULL && *error != nil) {
        return nil;
    }
    
    if (primaryKeys == nil) {
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    RNDRow *row = [self.rowCache rowForObjectID:@[[self referenceObjectForObjectID:objectID], relationship.entity]];
    [row.node setValue:primaryKeys forKey:@"destinationKeys"];
    //****************** END PRIMARY KEY PROCESSING ******************//
    
    
    //****************** BEGIN OBJECT ID PROCESSING ******************//
    NSMutableArray *objectIDs = [NSMutableArray new];
    for (NSString *primaryKey in primaryKeys) {
        [objectIDs addObject:[self newObjectIDForEntity:relationship.destinationEntity referenceObject:primaryKey]];
    }
    
    return relationship.isToMany == YES ? objectIDs : objectIDs.firstObject;
    //****************** END OBJECT ID PROCESSING ******************//
}

- (NSArray<NSManagedObjectID *> *)obtainPermanentIDsForObjects:(NSArray<NSManagedObject *> *)array
                                                         error:(NSError * _Nullable *)error {
    NSMutableArray *objectIDs = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSManagedObject *managedObject in array) {
        NSManagedObjectID *objectID = [self newObjectIDForEntity:managedObject.entity referenceObject:[NSUUID new].UUIDString];
        [objectIDs addObject:objectID];
    }
    
    return objectIDs;
    
}

+ (id)identifierForNewStoreAtURL:(NSURL *)storeURL {
    return nil;
}

- (void)managedObjectContextDidRegisterObjectsWithIDs:(NSArray<NSManagedObjectID *> *)objectIDs {
    for (NSManagedObjectID *objectID in objectIDs) {
        [self.rowCache incrementReferenceCountForObjectID:@[[self referenceObjectForObjectID:objectID], objectID.entity.name]];
    }
    return;
}

- (void)managedObjectContextDidUnregisterObjectsWithIDs:(NSArray<NSManagedObjectID *> *)objectIDs {
    for (NSManagedObjectID *objectID in objectIDs) {
        [self.rowCache decrementReferenceCountForObjectID:@[[self referenceObjectForObjectID:objectID], objectID.entity.name]];
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
        // TODO: ADD ASYNC OPTION
        // To support async, just return nil and dispatch this wrapped in a block that will update the row cache with the returned data and then dispatch a notification with the data update.
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
    
    //****************** BEGIN CACHE POLICY PROCESSING ******************//
    NSTimeInterval serviceRequestTimeout = 120;
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
        cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    //****************** END CACHE POLICY PROCESSING ******************//
    
    return [NSURLRequest requestWithURL:URL
                            cachePolicy:cachePolicy
                        timeoutInterval:serviceRequestTimeout];
}

- (NSCachedURLResponse *)cachedResponseForServiceRequest:(NSURLRequest *)serviceRequest
                                     forRequestingEntity:(NSEntityDescription *)entity
                                             withContext:(NSManagedObjectContext *)context {
    
    //****************** BEGIN CACHE RESPONSE PROCESSING ******************//
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
    
    //****************** END CACHE RESPONSE PROCESSING ******************//
    
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
        NSURLSession *loadingSession = (loadingPriority == QOS_CLASS_USER_INITIATED ||
                                        loadingPriority == QOS_CLASS_USER_INTERACTIVE ||
                                        loadingPriority == QOS_CLASS_UNSPECIFIED ||
                                        loadingPriority == QOS_CLASS_DEFAULT) ?
        self.priorityDataRequestSession :
        self.backgroundDataRequestSession;
        NSURLSessionDataTask *task = [loadingSession dataTaskWithRequest:serviceRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            //////////////////////////////////////////////////////
            ///////////////////// CHECKPOINT /////////////////////
            //////////////////////////////////////////////////////
            
            if (error != NULL) {
                serviceError = error;
                dispatch_semaphore_signal(sema);
                return;
            }
            
            if (error != NULL &&
                [response isKindOfClass:[NSHTTPURLResponse class]] == YES &&
                ((NSHTTPURLResponse *)response).statusCode > 299) {
                serviceError = [NSError errorWithDomain:@"RNDCoreDataDomain"
                                                   code:200500
                                               userInfo:@{@"RNDURLStatusCodeError":[NSString stringWithFormat:@"%ld", ((NSHTTPURLResponse *)response).statusCode]}];
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
    
    if (serviceError != nil) {
        if (error != NULL) {
            *error = serviceError;
        }
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
                                                      HTTPVersion:@"HTTP/1.1"
                                                     headerFields:headerDictionary];
        }
        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:httpResponse
                                                                                       data:serviceData
                                                                                   userInfo:nil
                                                                              storagePolicy:NSURLCacheStorageAllowed];
        [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse
                                              forRequest:serviceRequest];
        
    }
    
    return serviceData;
    //****************** END DATA RESPONSE PROCESSING ******************//
}

@end


