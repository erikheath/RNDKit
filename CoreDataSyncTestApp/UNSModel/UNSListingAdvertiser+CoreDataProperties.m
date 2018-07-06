//
//  UNSListingAdvertiser+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
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

@end
