//
//  UNSImage+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/4/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSImage+CoreDataProperties.h"

@implementation UNSImage (CoreDataProperties)

+ (NSFetchRequest<UNSImage *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSImage"];
}

@dynamic descriptionText;
@dynamic image;
@dynamic location;
@dynamic titleText;
@dynamic listing;

@end
