//
//  UNSListing+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSListing+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSListing (CoreDataProperties)

+ (NSFetchRequest<UNSListing *> *)fetchRequest;

@property (nonatomic) int16_t daysOnMarket;
@property (nullable, nonatomic, copy) NSString *descriptionText;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nonatomic) BOOL isNewConstruction;
@property (nullable, nonatomic, copy) NSString *marketIdentifier;
@property (nullable, nonatomic, copy) NSString *marketSource;
@property (nullable, nonatomic, copy) NSString *price;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, retain) NSOrderedSet<UNSImage *> *images;
@property (nullable, nonatomic, retain) NSSet<UNSListingAdvertiser *> *listingAdvertisers;
@property (nullable, nonatomic, retain) UNSProperty *propertyDescription;
@property (nullable, nonatomic, retain) NSSet<UNSSavedSet *> *savedSets;
@property (nullable, nonatomic, retain) UNSSchool *schools;
@property (nullable, nonatomic, retain) NSSet<UNSGeoLocation *> *searchSets;
@property (nullable, nonatomic, retain) UNSVideos *videos;

@end

@interface UNSListing (CoreDataGeneratedAccessors)

- (void)insertObject:(UNSImage *)value inImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromImagesAtIndex:(NSUInteger)idx;
- (void)insertImages:(NSArray<UNSImage *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInImagesAtIndex:(NSUInteger)idx withObject:(UNSImage *)value;
- (void)replaceImagesAtIndexes:(NSIndexSet *)indexes withImages:(NSArray<UNSImage *> *)values;
- (void)addImagesObject:(UNSImage *)value;
- (void)removeImagesObject:(UNSImage *)value;
- (void)addImages:(NSOrderedSet<UNSImage *> *)values;
- (void)removeImages:(NSOrderedSet<UNSImage *> *)values;

- (void)addListingAdvertisersObject:(UNSListingAdvertiser *)value;
- (void)removeListingAdvertisersObject:(UNSListingAdvertiser *)value;
- (void)addListingAdvertisers:(NSSet<UNSListingAdvertiser *> *)values;
- (void)removeListingAdvertisers:(NSSet<UNSListingAdvertiser *> *)values;

- (void)addSavedSetsObject:(UNSSavedSet *)value;
- (void)removeSavedSetsObject:(UNSSavedSet *)value;
- (void)addSavedSets:(NSSet<UNSSavedSet *> *)values;
- (void)removeSavedSets:(NSSet<UNSSavedSet *> *)values;

- (void)addSearchSetsObject:(UNSGeoLocation *)value;
- (void)removeSearchSetsObject:(UNSGeoLocation *)value;
- (void)addSearchSets:(NSSet<UNSGeoLocation *> *)values;
- (void)removeSearchSets:(NSSet<UNSGeoLocation *> *)values;

@end

NS_ASSUME_NONNULL_END
