//
//  UNSGeoLocation+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSGeoLocation+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSGeoLocation (CoreDataProperties)

+ (NSFetchRequest<UNSGeoLocation *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSObject *bottomRightCoordinateBoundary;
@property (nullable, nonatomic, retain) NSObject *boundaryCoordinates;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSDate *creationTimestamp;
@property (nullable, nonatomic, copy) NSString *descriptionText;
@property (nullable, nonatomic, retain) NSObject *locationCoordinates;
@property (nonatomic) double locationRadiusBoundary;
@property (nullable, nonatomic, copy) NSString *postalCode;
@property (nullable, nonatomic, copy) NSString *state;
@property (nullable, nonatomic, copy) NSString *titleText;
@property (nullable, nonatomic, retain) NSObject *topLeftCoordinateBoundary;
@property (nullable, nonatomic, retain) NSSet<UNSListing *> *listings;
@property (nullable, nonatomic, retain) UNSSearchProfile *searchProfile;

@end

@interface UNSGeoLocation (CoreDataGeneratedAccessors)

- (void)addListingsObject:(UNSListing *)value;
- (void)removeListingsObject:(UNSListing *)value;
- (void)addListings:(NSSet<UNSListing *> *)values;
- (void)removeListings:(NSSet<UNSListing *> *)values;

@end

NS_ASSUME_NONNULL_END
