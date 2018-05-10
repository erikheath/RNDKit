//
//  UNSListingAdvertiser+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSListingAdvertiser+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSListingAdvertiser (CoreDataProperties)

+ (NSFetchRequest<UNSListingAdvertiser *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *externalID;
@property (nullable, nonatomic, copy) NSString *licenseNumber;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, retain) UNSListing *listing;

@end

NS_ASSUME_NONNULL_END
