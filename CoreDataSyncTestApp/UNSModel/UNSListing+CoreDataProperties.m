//
//  UNSListing+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/4/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSListing+CoreDataProperties.h"

@implementation UNSListing (CoreDataProperties)

+ (NSFetchRequest<UNSListing *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSListing"];
}

@dynamic daysOnMarket;
@dynamic descriptionText;
@dynamic identifier;
@dynamic isNewConstruction;
@dynamic marketIdentifier;
@dynamic marketSource;
@dynamic price;
@dynamic status;
@dynamic images;
@dynamic listingAgent;
@dynamic listingOffice;
@dynamic propertyDescription;
@dynamic savedSets;
@dynamic searchSets;
@dynamic videos;

@end
