//
//  UNSVideos+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSVideos+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSVideos (CoreDataProperties)

+ (NSFetchRequest<UNSVideos *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *descriptionText;
@property (nullable, nonatomic, copy) NSURL *location;
@property (nullable, nonatomic, copy) NSString *titleText;
@property (nullable, nonatomic, retain) UNSListing *listing;

@end

NS_ASSUME_NONNULL_END
