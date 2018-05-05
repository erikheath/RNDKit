//
//  UNSSavedSet+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/4/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSSavedSet+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSSavedSet (CoreDataProperties)

+ (NSFetchRequest<UNSSavedSet *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *setName;
@property (nullable, nonatomic, retain) NSOrderedSet<UNSListing *> *listing;

@end

@interface UNSSavedSet (CoreDataGeneratedAccessors)

- (void)insertObject:(UNSListing *)value inListingAtIndex:(NSUInteger)idx;
- (void)removeObjectFromListingAtIndex:(NSUInteger)idx;
- (void)insertListing:(NSArray<UNSListing *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeListingAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInListingAtIndex:(NSUInteger)idx withObject:(UNSListing *)value;
- (void)replaceListingAtIndexes:(NSIndexSet *)indexes withListing:(NSArray<UNSListing *> *)values;
- (void)addListingObject:(UNSListing *)value;
- (void)removeListingObject:(UNSListing *)value;
- (void)addListing:(NSOrderedSet<UNSListing *> *)values;
- (void)removeListing:(NSOrderedSet<UNSListing *> *)values;

@end

NS_ASSUME_NONNULL_END
