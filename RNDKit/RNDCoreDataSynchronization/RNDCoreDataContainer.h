//
//  RNDCoreDataContainer.h
//  RNDKit
//
//  Created by Erikheath Thomas on 4/26/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RNDCoreDataContainer : NSObject


/**
 The persistent store coordinator of the container.
 */
@property(strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


/**
 The assigned name of the container.
 */
@property(copy, readonly) NSString *name;


/**
 The merged object model used by the container.
 */
@property(strong, readonly) NSManagedObjectModel *managedObjectModel;


/**
 <#Description#>
 */
@property(copy) NSArray<NSPersistentStoreDescription *> *persistentStoreDescriptions;


/**
 The context provided by the container for operations on the main queue. Use the view context for all fetch, save, and delete operations driven by the UI.
 */
@property(strong, readonly) NSManagedObjectContext *viewContext;

- (instancetype)initWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name
          managedObjectModel:(NSManagedObjectModel *)model;

+ (instancetype)persistentContainerWithName:(NSString *)name;

+ (instancetype)persistentContainerWithName:(NSString *)name
                         managedObjectModel:(NSManagedObjectModel *)model;

+ (NSURL *)defaultDirectoryURL;

// - (void)loadPersistentStoresWithCompletionHandler:(void (^)(NSPersistentStoreDescription *, NSError *))block;

- (NSManagedObjectContext *)newBackgroundContext;

- (void)performBackgroundTask:(void (^)(NSManagedObjectContext *))block;

@end
