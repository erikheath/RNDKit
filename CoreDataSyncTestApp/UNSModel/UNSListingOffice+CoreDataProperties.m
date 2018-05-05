//
//  UNSListingOffice+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/4/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSListingOffice+CoreDataProperties.h"

@implementation UNSListingOffice (CoreDataProperties)

+ (NSFetchRequest<UNSListingOffice *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSListingOffice"];
}

@dynamic externalID;
@dynamic name;
@dynamic phone;
@dynamic listing;

@end
