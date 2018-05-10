//
//  UNSGeoLocation+CoreDataProperties.m
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSGeoLocation+CoreDataProperties.h"

@implementation UNSGeoLocation (CoreDataProperties)

+ (NSFetchRequest<UNSGeoLocation *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"UNSGeoLocation"];
}

@dynamic bottomRightCoordinateBoundary;
@dynamic boundaryCoordinates;
@dynamic city;
@dynamic creationTimestamp;
@dynamic descriptionText;
@dynamic locationCoordinates;
@dynamic locationRadiusBoundary;
@dynamic postalCode;
@dynamic state;
@dynamic titleText;
@dynamic topLeftCoordinateBoundary;
@dynamic listings;
@dynamic searchProfile;

@end
