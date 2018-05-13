//
//  RNDIncrementalStore.h
//  RNDKit
//
//  Created by Erikheath Thomas on 12/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RNDRowCache.h"
#import "RNDQueryItemPredicateParser.h"
#import "RNDResponseProcessor.h"


@protocol RNDIncrementalStoreDataRequestDelegate <NSURLSessionDelegate>

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

@protocol RNDIncrementalStoreDataResponseDelegate <NSObject>


@end

/**
 The RNDIncrementalStore provides incremental access to a datastore.
 */
@interface RNDIncrementalStore: NSIncrementalStore

@property (weak, nullable, nonatomic, readwrite) id storeDelegate;


@property (strong, nonnull, nonatomic, readonly) RNDRowCache *rowCache;


@property (strong, nonnull, nonatomic, readwrite) NSURLCache *dataCache;

@property (readwrite) NSURLCacheStoragePolicy dataCacheStoragePolicy;

@property (readwrite) NSTimeInterval dataCacheExpirationInterval;


@property (strong, nonnull, nonatomic, readwrite) NSURLSession *dataRequestSession;

@property (strong, nonnull, nonatomic, readwrite) NSURLSessionConfiguration *dataRequestConfigfuration;

@property (weak, nullable, nonatomic, readwrite) id<RNDIncrementalStoreDataRequestDelegate> dataRequestDelegate;

@property (strong, nonnull, nonatomic, readonly) NSOperationQueue *dataRequestDelegateQueue;

@property (strong, nonnull, nonatomic, readwrite) RNDQueryItemPredicateParser *dataRequestQueryItemPredicateParser;


@property (weak, nullable, nonatomic, readwrite) id<RNDIncrementalStoreDataResponseDelegate> dataResponseDelegate;

@property (strong, nonnull, nonatomic, readonly) NSOperationQueue *dataResponseDelegateQueue;

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
