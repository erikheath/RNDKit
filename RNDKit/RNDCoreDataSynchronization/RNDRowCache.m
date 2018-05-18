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

@synthesize primaryKey = _primaryKey;

@synthesize entityName = _entityName;

- (BOOL)isExpried {
    return [[NSDate date] compare:self.expirationDate] == NSOrderedDescending ? YES : NO;
}

- (instancetype)init {
    // TODO: Add an exception NS_NOT_IMPLEMENTED
    return nil;
}

- (instancetype)initWithNode:(NSIncrementalStoreNode *)node
                 lastUpdated:(NSDate *)lastUpdated
          expirationInterval:(NSTimeInterval)interval
                  primaryKey:(NSString *)primaryKey
                  entityName:(NSString *)entityName{
    if ((self = [super init]) != nil) {
        _node = node;
        _lastUpdated = lastUpdated;
        _expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        _primaryKey = primaryKey;
        _entityName = entityName;
    }
    return self;
}

- (void)updateRowExpiration:(NSTimeInterval)interval {
    _expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
}

@end


@interface RNDRowCache ()

@property (strong, nonnull, nonatomic, readonly) NSMutableDictionary *rowCache;

@property (strong, nonnull, nonatomic, readonly) NSCountedSet *referenceCounter;

@property (strong, nonnull, nonatomic, readonly) NSRecursiveLock *lock;

@end

@implementation RNDRowCache

@synthesize rowCache = _rowCache;

@synthesize referenceCounter = _referenceCounter;

@synthesize lock = _lock;

- (instancetype)init {
    if ((self = [super init]) != nil) {
        _rowCache = [NSMutableDictionary new];
        _referenceCounter = [NSCountedSet new];
        NSString *label = [[NSUUID UUID] UUIDString];
        label = [@"syncLock: " stringByAppendingString:label];
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = label;
    }
    return self;
}

- (RNDRow *)rowForObjectID:(NSArray *)objectID {
    RNDRow *row = nil;
    [_lock lock];
    row = self.rowCache[objectID];
    [_lock unlock];
    return row;
}

- (void)addRow:(RNDRow *)row {
    [_lock lock];
    [self.rowCache setObject:row forKey:@[row.primaryKey, row.entityName]];
    [_lock unlock];
}

- (void)removeRowForObjectID:(NSArray *)objectID {
    [_lock lock];
    [self.rowCache removeObjectForKey:objectID];
    [self removeReferenceCountForObjectID:objectID];
    [_lock unlock];
}

- (void)registerRow:(RNDRow *)row {
    [_lock lock];
    [self.rowCache setObject:row forKey:@[row.primaryKey, row.entityName]];
    [self incrementReferenceCountForObjectID:@[row.primaryKey, row.entityName]];
    [_lock unlock];
}

- (void)incrementReferenceCountForObjectID:(NSArray *)objectID {
    [_lock lock];
    [self.referenceCounter addObject:objectID];
    [_lock unlock];
}

- (void)decrementReferenceCountForObjectID:(NSArray *)objectID {
    [_lock lock];
    [self.referenceCounter removeObject:objectID];
    if ([self.referenceCounter countForObject:objectID] == 0) {
        [self removeRowForObjectID:objectID];
    }
    [_lock unlock];
}

- (void)removeReferenceCountForObjectID:(NSArray *)objectID {
    [_lock lock];
    for (NSUInteger count = [self.referenceCounter countForObject:objectID]; count > 0; count--) {
        [self.referenceCounter removeObject:objectID];
    }
    [_lock unlock];
}

- (NSDictionary *)expiredRows {
    [_lock lock];
    NSMutableDictionary *rows = [NSMutableDictionary new];
    NSDate *currentDate = [NSDate date];
    for (NSManagedObjectID *objectID in self.rowCache) {
        RNDRow *row = self.rowCache[objectID];
        if ([currentDate compare:row.expirationDate] == NSOrderedAscending) {
            [rows setObject:row forKey:objectID];
        }
    }
    [_lock unlock];
    return [NSDictionary dictionaryWithDictionary:rows];
}

- (NSDictionary *)pruneExpiredRows {
    [_lock lock];
    NSDictionary *rows = [self expiredRows];
    for (NSArray *objectID in rows) {
        [self removeRowForObjectID:objectID];
    }
    [_lock unlock];
    return rows;
}

@end
