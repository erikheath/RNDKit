//
//  UNSSearchProfile+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSSearchProfile+CoreDataProperties.h"

@implementation UNSSearchProfile (CoreDataProperties)

+ (NSFetchRequest<UNSSearchProfile *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSSearchProfile"];
}

@dynamic city;
@dynamic creationTimestamp;
@dynamic descriptionText;
@dynamic downPayment;
@dynamic geohash;
@dynamic listingIdentifier;
@dynamic listingStatus;
@dynamic locationCoordinates;
@dynamic locationRadiusBoundary;
@dynamic marketIdentifier;
@dynamic maxBathrooms;
@dynamic maxBedrooms;
@dynamic minbathrooms;
@dynamic minbedrooms;
@dynamic monthlyPayment;
@dynamic points;
@dynamic postalCode;
@dynamic propertyKind;
@dynamic state;
@dynamic titleText;
@dynamic listings;

@end
