//
//  UNSProperty+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/4/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSProperty+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSProperty (CoreDataProperties)

+ (NSFetchRequest<UNSProperty *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDecimalNumber *bathrooms;
@property (nonatomic) int16_t bedrooms;
@property (nullable, nonatomic, copy) NSString *city;
@property (nullable, nonatomic, copy) NSString *county;
@property (nullable, nonatomic, copy) NSDate *dateBuilt;
@property (nonatomic) int16_t floor;
@property (nullable, nonatomic, retain) NSObject *geoLocation;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSString *kind;
@property (nullable, nonatomic, copy) NSString *neighborhood;
@property (nullable, nonatomic, copy) NSDecimalNumber *parkingSpaces;
@property (nullable, nonatomic, copy) NSString *postalCode;
@property (nonatomic) int16_t sizeOfHome;
@property (nonatomic) int16_t sizeOfLot;
@property (nullable, nonatomic, copy) NSString *state;
@property (nonatomic) int16_t stories;
@property (nullable, nonatomic, copy) NSString *street;
@property (nullable, nonatomic, copy) NSString *style;
@property (nullable, nonatomic, retain) UNSListing *listing;

@end

NS_ASSUME_NONNULL_END
