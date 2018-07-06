//
//  UNSProperty+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
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
@dynamic geohash10;
@dynamic identifier;
@dynamic kind;
@dynamic latitude;
@dynamic longitude;
@dynamic neighborhood;
@dynamic parkingSpaces;
@dynamic postalCode;
@dynamic sizeOfHome;
@dynamic sizeOfLot;
@dynamic state;
@dynamic stories;
@dynamic street;
@dynamic style;

@end
