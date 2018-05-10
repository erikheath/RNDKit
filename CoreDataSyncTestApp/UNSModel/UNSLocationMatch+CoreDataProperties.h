//
//  UNSLocationMatch+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSLocationMatch+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSLocationMatch (CoreDataProperties)

+ (NSFetchRequest<UNSLocationMatch *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *descriptionText;
@property (nullable, nonatomic, copy) NSString *kind;
@property (nullable, nonatomic, copy) NSString *searchID;
@property (nullable, nonatomic, copy) NSString *titleText;

@end

NS_ASSUME_NONNULL_END
