//
//  RNDRowCache.m
//  RNDKit
//
//  Created by Erikheath Thomas on 5/8/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDRowCache.h"

@implementation RNDRow

@synthesize expirationDate = _expirationDate;

@synthesize node = _node;

- (instancetype)init {
    // TODO: Add an exception NS_NOT_IMPLEMENTED
    return nil;
}

- (instancetype)initWithNode:(NSIncrementalStoreNode *)node
          expirationInterval:(NSTimeInterval)interval {
    if ((self = [super init]) != nil) {
        _node = node;
        _expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    }
    return self;
}

@end


@interface RNDRowCache ()

@property (strong, nonnull, nonatomic, readonly) NSMutableDictionary *rowCache;

@property (strong, nonnull, nonatomic, readonly) NSCountedSet *referenceCounter;

@end

@implementation RNDRowCache

@synthesize rowCache = _rowCache;

@synthesize referenceCounter = _referenceCounter;

- (NSMutableDictionary *)rowCache {
    if (_rowCache == nil) {
        _rowCache = [NSMutableDictionary new];
    }
    return _rowCache;
}

- (NSCountedSet *)referenceCounter {
    if (_referenceCounter == nil) {
        _referenceCounter = [NSCountedSet new];
    }
    return _referenceCounter;
}

- (RNDRow *)rowForObjectID:(NSManagedObjectID *)objectID {
    return self.rowCache[objectID];
}

- (void)addRow:(RNDRow *)row forObjectID:(NSManagedObjectID *)objectID {
    [self.rowCache setObject:row forKey:objectID];
}

- (void)removeRowForObjectID:(NSManagedObjectID *)objectID {
    [self.rowCache removeObjectForKey:objectID];
    [self removeReferenceCountForObjectID:objectID];
}

- (void)registerRow:(RNDRow *)row forObjectID:(NSManagedObjectID *)objectID {
    [self.rowCache setObject:row forKey:objectID];
    [self incrementReferenceCountForObjectID:objectID];
}

- (void)incrementReferenceCountForObjectID:(NSManagedObjectID *)objectID {
    [self.referenceCounter addObject:objectID];
}

- (void)decrementReferenceCountForObjectID:(NSManagedObjectID *)objectID {
    [self.referenceCounter removeObject:objectID];
    if ([self.referenceCounter countForObject:objectID] == 0) {
        [self removeRowForObjectID:objectID];
    }
}

- (void)removeReferenceCountForObjectID:(NSManagedObjectID *)objectID {
    for (NSUInteger count = [self.referenceCounter countForObject:objectID]; count > 0; count--) {
        [self.referenceCounter removeObject:objectID];
    }
}

- (NSDictionary *)expiredRows {
    NSMutableDictionary *rows = [NSMutableDictionary new];
    NSDate *currentDate = [NSDate date];
    for (NSManagedObjectID *objectID in self.rowCache) {
        RNDRow *row = self.rowCache[objectID];
        if ([currentDate compare:row.expirationDate] == NSOrderedAscending) {
            [rows setObject:row forKey:objectID];
        }
    }
    return [NSDictionary dictionaryWithDictionary:rows];
}

- (NSDictionary *)pruneExpiredRows {
    NSDictionary *rows = [self expiredRows];
    for (NSManagedObjectID *objectID in rows) {
        [self removeRowForObjectID:objectID];
    }
    return rows;
}

@end
