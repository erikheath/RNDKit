//
//  UNSImage+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSImage+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSImage (CoreDataProperties)

+ (NSFetchRequest<UNSImage *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *image;

@end

NS_ASSUME_NONNULL_END
