//
//  UNSSearchProfile+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSSearchProfile+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSSearchProfile (CoreDataProperties)

+ (NSFetchRequest<UNSSearchProfile *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSDate *creationTimestamp;
@property (nullable, nonatomic, copy) NSString *descriptionText;
@property (nonatomic) int16_t downPayment;
@property (nullable, nonatomic, copy) NSString *geohash;
@property (nullable, nonatomic, copy) NSString *listingIdentifier;
@property (nullable, nonatomic, copy) NSString *listingStatus;
@property (nullable, nonatomic, retain) NSObject *locationCoordinates;
@property (nonatomic) double locationRadiusBoundary;
@property (nullable, nonatomic, copy) NSString *marketIdentifier;
@property (nullable, nonatomic, copy) NSDecimalNumber *maxBathrooms;
@property (nullable, nonatomic, copy) NSDecimalNumber *maxBedrooms;
@property (nullable, nonatomic, copy) NSDecimalNumber *minbathrooms;
@property (nullable, nonatomic, copy) NSDecimalNumber *minbedrooms;
@property (nonatomic) int16_t monthlyPayment;
@property (nullable, nonatomic, copy) NSString *points;
@property (nullable, nonatomic, copy) NSString *postalCode;
@property (nullable, nonatomic, copy) NSString *propertyKind;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, copy) NSString *titleText;
@property (nullable, nonatomic, retain) NSOrderedSet<UNSListing *> *listings;

@end

@interface UNSSearchProfile (CoreDataGeneratedAccessors)

- (void)insertObject:(UNSListing *)value inListingsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromListingsAtIndex:(NSUInteger)idx;
- (void)insertListings:(NSArray<UNSListing *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeListingsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInListingsAtIndex:(NSUInteger)idx withObject:(UNSListing *)value;
- (void)replaceListingsAtIndexes:(NSIndexSet *)indexes withListings:(NSArray<UNSListing *> *)values;
- (void)addListingsObject:(UNSListing *)value;
- (void)removeListingsObject:(UNSListing *)value;
- (void)addListings:(NSOrderedSet<UNSListing *> *)values;
- (void)removeListings:(NSOrderedSet<UNSListing *> *)values;

@end

NS_ASSUME_NONNULL_END
