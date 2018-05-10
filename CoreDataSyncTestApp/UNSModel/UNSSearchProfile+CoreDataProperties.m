//
//  UNSSearchProfile+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSSearchProfile+CoreDataProperties.h"

@implementation UNSSearchProfile (CoreDataProperties)

+ (NSFetchRequest<UNSSearchProfile *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSSearchProfile"];
}

@dynamic city;
@dynamic downPayment;
@dynamic listingIdentifier;
@dynamic listingStatus;
@dynamic marketIdentifier;
@dynamic maxBathrooms;
@dynamic maxBedrooms;
@dynamic minbathrooms;
@dynamic minbedrooms;
@dynamic monthlyPayment;
@dynamic propertyKind;
@dynamic locations;

@end
