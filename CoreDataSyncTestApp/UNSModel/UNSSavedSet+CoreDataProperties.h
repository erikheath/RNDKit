//
//  UNSSavedSet+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSSavedSet+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSSavedSet (CoreDataProperties)

+ (NSFetchRequest<UNSSavedSet *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *setName;

@end

NS_ASSUME_NONNULL_END
