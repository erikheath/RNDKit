//
//  UNSProperty+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/4/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSProperty+CoreDataProperties.h"

@implementation UNSProperty (CoreDataProperties)

+ (NSFetchRequest<UNSProperty *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSProperty"];
}

@dynamic bathrooms;
@dynamic bedrooms;
@dynamic city;
@dynamic county;
@dynamic dateBuilt;
@dynamic floor;
@dynamic geoLocation;
@dynamic identifier;
@dynamic kind;
@dynamic neighborhood;
@dynamic parkingSpaces;
@dynamic postalCode;
@dynamic sizeOfHome;
@dynamic sizeOfLot;
@dynamic state;
@dynamic stories;
@dynamic street;
@dynamic style;
@dynamic listing;

@end
