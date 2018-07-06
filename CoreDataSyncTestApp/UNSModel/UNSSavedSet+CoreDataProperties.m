//
//  UNSSavedSet+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSSavedSet+CoreDataProperties.h"

@implementation UNSSavedSet (CoreDataProperties)

+ (NSFetchRequest<UNSSavedSet *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSSavedSet"];
}

@dynamic setName;

@end
