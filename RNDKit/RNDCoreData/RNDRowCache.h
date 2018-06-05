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

@property (strong, nonnull, nonatomic, readonly) NSString *primaryKey;

@property (strong, nonnull, nonatomic, readonly) NSString *entityName;

@property (readonly) BOOL isExpried;

- (instancetype)initWithNode:(NSIncrementalStoreNode *)node
                 lastUpdated:(NSDate *)lastUpdated
          expirationInterval:(NSTimeInterval)interval
                  primaryKey:(NSString *)primaryKey
                  entityName:(NSString *)entityName;

- (void)updateRowExpiration:(NSTimeInterval)interval;

@end

@interface RNDRowCache: NSObject

- (RNDRow *)rowForObjectID:(NSArray *)objectID;

- (void)addRow:(RNDRow *)row;

- (void)removeRowForObjectID:(NSArray *)objectID;

- (void)registerRow:(RNDRow *)row;

- (void)incrementReferenceCountForObjectID:(NSArray *)objectID;

- (void)decrementReferenceCountForObjectID:(NSArray *)objectID;

- (void)removeReferenceCountForObjectID:(NSArray *)objectID;

- (NSDictionary *)expiredRows;

- (NSDictionary *)pruneExpiredRows;


@end

