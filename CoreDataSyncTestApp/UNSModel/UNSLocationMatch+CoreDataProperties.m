//
//  UNSLocationMatch+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSLocationMatch+CoreDataProperties.h"

@implementation UNSLocationMatch (CoreDataProperties)

+ (NSFetchRequest<UNSLocationMatch *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSLocationMatch"];
}

@dynamic descriptionText;
@dynamic kind;
@dynamic searchID;
@dynamic titleText;

@end
