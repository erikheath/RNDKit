//
//  RNDIncrementalStore.h
//  RNDKit
//
//  Created by Erikheath Thomas on 12/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


/**
 The RNDIncrementalStore provides incremental access to a datastore.
 */
@interface RNDIncrementalStore: NSIncrementalStore

@property (strong, nonnull, nonatomic, readwrite) NSURLCache *dataCache;
@property (readwrite) NSURLCacheStoragePolicy dataCacheStoragePolicy;

@property (strong, nonnull, nonatomic, readwrite) NSURLSession *dataRequestSession;
@property (strong, nonnull, nonatomic, readwrite) NSURLSessionConfiguration *dataRequestConfigfuration;
@property (weak, nullable, nonatomic, readwrite) id<NSURLSessionDelegate> dataRequestDelegate;
@property (strong, nonnull, nonatomic, readonly) NSOperationQueue *dataRequestDelegateQueue;

@end
