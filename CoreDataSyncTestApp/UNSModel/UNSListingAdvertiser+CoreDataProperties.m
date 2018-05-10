//
//  UNSListingAdvertiser+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSListingAdvertiser+CoreDataProperties.h"

@implementation UNSListingAdvertiser (CoreDataProperties)

+ (NSFetchRequest<UNSListingAdvertiser *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSListingAdvertiser"];
}

@dynamic email;
@dynamic externalID;
@dynamic licenseNumber;
@dynamic name;
@dynamic phone;
@dynamic listing;

@end
