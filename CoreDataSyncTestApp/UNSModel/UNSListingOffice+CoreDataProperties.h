//
//  UNSListingOffice+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/4/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSListingOffice+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSListingOffice (CoreDataProperties)

+ (NSFetchRequest<UNSListingOffice *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *externalID;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, retain) UNSListing *listing;

@end

NS_ASSUME_NONNULL_END
