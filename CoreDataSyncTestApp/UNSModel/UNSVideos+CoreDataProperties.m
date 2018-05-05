//
//  UNSVideos+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/4/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSVideos+CoreDataProperties.h"

@implementation UNSVideos (CoreDataProperties)

+ (NSFetchRequest<UNSVideos *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSVideos"];
}

@dynamic descriptionText;
@dynamic location;
@dynamic titleText;
@dynamic listing;

@end
