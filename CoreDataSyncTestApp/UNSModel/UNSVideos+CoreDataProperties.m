//
//  UNSVideos+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
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

@end
