//
//  UNSSchool+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSSchool+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSSchool (CoreDataProperties)

+ (NSFetchRequest<UNSSchool *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *elementarySchool;
@property (nullable, nonatomic, copy) NSString *highSchool;
@property (nullable, nonatomic, copy) NSString *middleSchool;
@property (nullable, nonatomic, copy) NSString *schoolDistrict;
@property (nullable, nonatomic, retain) UNSListing *listing;

@end

NS_ASSUME_NONNULL_END
