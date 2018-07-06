//
//  UNSSchool+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSSchool+CoreDataProperties.h"

@implementation UNSSchool (CoreDataProperties)

+ (NSFetchRequest<UNSSchool *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSSchool"];
}

@dynamic elementarySchool;
@dynamic highSchool;
@dynamic middleSchool;
@dynamic schoolDistrict;

@end
