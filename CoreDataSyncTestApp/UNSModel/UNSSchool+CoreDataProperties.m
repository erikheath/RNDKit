//
//  UNSSchool+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
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
@dynamic listing;

@end
