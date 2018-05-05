//
//  UNSLisingAgent+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/4/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSLisingAgent+CoreDataProperties.h"

@implementation UNSLisingAgent (CoreDataProperties)

+ (NSFetchRequest<UNSLisingAgent *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSLisingAgent"];
}

@dynamic email;
@dynamic externalID;
@dynamic licenseNumber;
@dynamic name;
@dynamic phone;
@dynamic listing;

@end
