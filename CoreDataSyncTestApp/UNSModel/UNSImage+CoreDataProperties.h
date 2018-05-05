//
//  UNSImage+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/4/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSImage+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSImage (CoreDataProperties)

+ (NSFetchRequest<UNSImage *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *descriptionText;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, copy) NSURL *location;
@property (nullable, nonatomic, copy) NSString *titleText;
@property (nullable, nonatomic, retain) UNSListing *listing;

@end

NS_ASSUME_NONNULL_END
