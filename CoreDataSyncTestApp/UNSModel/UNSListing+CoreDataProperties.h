//
//  UNSListing+CoreDataProperties.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 6/25/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//
//

#import "UNSListing+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UNSListing (CoreDataProperties)

+ (NSFetchRequest<UNSListing *> *)fetchRequest;

@property (nonatomic) int16_t daysOnMarket;
@property (nullable, nonatomic, copy) NSString *descriptionText;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nonatomic) BOOL isNewConstruction;
@property (nullable, nonatomic, copy) NSString *marketIdentifier;
@property (nullable, nonatomic, copy) NSString *marketSource;
@property (nonatomic) int64_t price;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, retain) NSOrderedSet<UNSImage *> *images;
@property (nullable, nonatomic, retain) UNSProperty *propertyDescription;

@end

@interface UNSListing (CoreDataGeneratedAccessors)

- (void)insertObject:(UNSImage *)value inImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromImagesAtIndex:(NSUInteger)idx;
- (void)insertImages:(NSArray<UNSImage *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInImagesAtIndex:(NSUInteger)idx withObject:(UNSImage *)value;
- (void)replaceImagesAtIndexes:(NSIndexSet *)indexes withImages:(NSArray<UNSImage *> *)values;
- (void)addImagesObject:(UNSImage *)value;
- (void)removeImagesObject:(UNSImage *)value;
- (void)addImages:(NSOrderedSet<UNSImage *> *)values;
- (void)removeImages:(NSOrderedSet<UNSImage *> *)values;

@end

NS_ASSUME_NONNULL_END
