//
//  RNDIncrementalStore.h
//  RNDKit
//
//  Created by Erikheath Thomas on 12/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RNDRowCache;
@class RNDQueryItemPredicateParser;
@protocol RNDResponseProcessor;

@protocol RNDIncrementalStoreDelegate <NSObject>

@end

@protocol RNDIncrementalStoreURLConstructionDelegate <NSObject>

@optional

- (BOOL)storeShouldSubstituteVariablesForRequest:(NSPersistentStoreRequest *)request;

- (NSDictionary *)substitutionDictionaryForRequest:(NSPersistentStoreRequest *)request
                              defaultSubstitutions:(NSDictionary *)defaultSubstitutions;

- (BOOL)storeShouldDelegateURLTemplateConstructionForRequest:(NSPersistentStoreRequest *)request;

- (NSString *)URLTempateForRequest:(NSPersistentStoreRequest *)request;

- (BOOL)storeShouldDelegateURLComponentConstructionForRequest:(NSPersistentStoreRequest *)request;

- (NSURLComponents *)URLComponentsForRequest:(NSPersistentStoreRequest *)request;

- (BOOL)storeShouldDelegateQueryItemConstructionForRequest:(NSPersistentStoreRequest *)request;

- (NSArray <NSURLQueryItem *> *)URLQueryItemsForRequest:(NSPersistentStoreRequest *)request;

@end

@protocol RNDIncrementalStoreDataIODelegate <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@end

@protocol RNDIncrementalStoreDataProcessingDelegate

@end

/**
 The RNDIncrementalStore provides incremental access to a datastore.
 */
@interface RNDIncrementalStore: NSIncrementalStore

@property (strong, nullable, nonatomic, readwrite) id<RNDIncrementalStoreDelegate> storeDelegate;

@property (strong, nonnull, nonatomic, readonly) RNDRowCache *rowCache;

@property (strong, nonnull, nonatomic, readwrite) NSURLCache *dataCache;

@property (readwrite) NSURLCacheStoragePolicy dataCacheStoragePolicy;

@property (readwrite) NSTimeInterval dataCacheExpirationInterval;

@property (strong, nonnull, nonatomic, readwrite) NSURLSession *backgroundDataRequestSession;

@property (strong, nonnull, nonatomic, readwrite) NSURLSessionConfiguration *backgroundDataRequestConfigfuration;

@property (strong, nonnull, nonatomic, readwrite) NSURLSession *priorityDataRequestSession;

@property (strong, nonnull, nonatomic, readwrite) NSURLSessionConfiguration *priorityDataRequestConfigfuration;

@property (strong, nullable, nonatomic, readwrite) id<RNDIncrementalStoreURLConstructionDelegate> URLConstructionDelegate;

@property (strong, nonnull, nonatomic, readonly) NSOperationQueue *URLConstructionDelegateQueue;

@property (strong, nonnull, nonatomic, readwrite) RNDQueryItemPredicateParser *dataRequestQueryItemPredicateParser;

@property (strong, nullable, nonatomic, readwrite) id<RNDIncrementalStoreDataIODelegate> dataDelegate;

@property (strong, nonnull, nonatomic, readonly) NSOperationQueue *dataDelegateQueue;

@property (strong, nonnull, nonatomic, readonly) NSMutableDictionary <NSString *, id<RNDResponseProcessor> > *dataResponseProcessors;

@end

/******************************************************
    BEGIN EXTENSION - REMOVE FROM PUBLIC DISTRIBUTION
 ******************************************************/

@class RNDBindingProcessor;
@class RNDIncrementalStoreConfiguration;

@interface RNDIncrementalStore(RNDBinderSupport)

@property (strong, nonnull, nonatomic, readonly) RNDIncrementalStoreConfiguration *RNDConfiguration;

@property (strong, nonnull, nonatomic, readonly) NSMutableDictionary<NSString *, RNDBindingProcessor *> *bindingProcessors;

- (void)addBindingProcessor:(RNDBindingProcessor *)processor forEntity:(NSEntityDescription *)entity;

- (RNDBindingProcessor *)removeBindingProcessorForEntity:(NSEntityDescription *)entity;

- (void)resetStoreWithRNDConfiguration:(RNDIncrementalStoreConfiguration *)configuration;

@end

/******************************************************
 END EXTENSION - REMOVE FROM PUBLIC DISTRIBUTION
 ******************************************************/
