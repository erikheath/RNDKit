//
//  UNSImage+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSImage+CoreDataProperties.h"

@implementation UNSImage (CoreDataProperties)

+ (NSFetchRequest<UNSImage *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSImage"];
}

@dynamic image;

@end
