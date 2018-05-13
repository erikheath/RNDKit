//
//  RNDRowCache.h
//  RNDKit
//
//  Created by Erikheath Thomas on 5/8/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RNDRow: NSObject

@property (strong, nonnull, nonatomic, readonly) NSDate *expirationDate;

@property (strong, nonnull, nonatomic, readonly) NSDate *lastUpdated;

@property (strong, nonnull, nonatomic, readonly) NSIncrementalStoreNode *node;

@property (readonly) BOOL isExpried;

- (instancetype)initWithNode:(NSIncrementalStoreNode *)node
                 lastUpdated:(NSDate *)lastUpdated
          expirationInterval:(NSTimeInterval)interval;

@end

@interface RNDRowCache: NSObject

- (RNDRow *)rowForObjectID:(NSManagedObjectID *)objectID;

- (void)addRow:(RNDRow *)row forObjectID:(NSManagedObjectID *)objectID;

- (void)removeRowForObjectID:(NSManagedObjectID *)objectID;

- (void)registerRow:(RNDRow *)row forObjectID:(NSManagedObjectID *)objectID;

- (void)incrementReferenceCountForObjectID:(NSManagedObjectID *)objectID;

- (void)decrementReferenceCountForObjectID:(NSManagedObjectID *)objectID;

- (void)removeReferenceCountForObjectID:(NSManagedObjectID *)objectID;

- (NSDictionary *)expiredRows;

- (NSDictionary *)pruneExpiredRows;


@end

