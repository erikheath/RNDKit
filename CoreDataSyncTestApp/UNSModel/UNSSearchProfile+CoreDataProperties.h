//
//  UNSSearchProfile+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSSearchProfile+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSSearchProfile (CoreDataProperties)

+ (NSFetchRequest<UNSSearchProfile *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *city;
@property (nonatomic) int16_t downPayment;
@property (nullable, nonatomic, copy) NSString *listingIdentifier;
@property (nullable, nonatomic, retain) NSObject *listingStatus;
@property (nullable, nonatomic, copy) NSString *marketIdentifier;
@property (nullable, nonatomic, copy) NSDecimalNumber *maxBathrooms;
@property (nullable, nonatomic, copy) NSDecimalNumber *maxBedrooms;
@property (nullable, nonatomic, copy) NSDecimalNumber *minbathrooms;
@property (nullable, nonatomic, copy) NSDecimalNumber *minbedrooms;
@property (nonatomic) int16_t monthlyPayment;
@property (nullable, nonatomic, retain) NSObject *propertyKind;
@property (nullable, nonatomic, retain) UNSGeoLocation *locations;

@end

NS_ASSUME_NONNULL_END
