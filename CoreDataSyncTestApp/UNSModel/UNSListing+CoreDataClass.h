//
//  UNSListing+CoreDataClass.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UNSGeoLocation, UNSImage, UNSListingAdvertiser, UNSProperty, UNSSavedSet, UNSSchool, UNSVideos;

NS_ASSUME_NONNULL_BEGIN

@interface UNSListing : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "UNSListing+CoreDataProperties.h"
