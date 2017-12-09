//
//  RNDObjectController.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/2/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RNDController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RNDControllerType) {
    RNDClassController,
    RNDProxyController
};

@interface RNDObjectController : RNDController { }

@property (nullable, strong) IBOutlet id content;
@property (readonly, strong) id selection;
@property (readonly, copy) NSArray *selectedObjects;
@property BOOL automaticallyPreparesContent;
@property (null_resettable, unsafe_unretained) Class objectClass;
@property (readonly) NSString *objectClassName;
@property (getter=isEditable) BOOL editable;
@property (readonly) BOOL canAdd;
@property (readonly) BOOL canRemove;
@property (readonly) BOOL hasLoadedData;
@property (readwrite) RNDControllerType controllerType;


- (instancetype)initWithContent:(nullable id)content NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (void)prepareContent;
- (id)newObject;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (IBAction)add:(nullable id)sender;
- (IBAction)remove:(nullable id)sender;
//- (BOOL)validateUserInterfaceItem:(id <RNDValidatedUserInterfaceItem>)item;

@end


#pragma mark -
@interface RNDObjectController (NSManagedController)

@property (nullable, strong) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nullable, copy) NSString *entityName;
@property (nullable, strong) NSPredicate *fetchPredicate;
@property (nullable, strong) NSFetchRequest *defaultFetchRequest;
@property BOOL usesLazyFetching;
@property (readonly) BOOL hasFetched;
@property (readonly) BOOL batches;

- (IBAction)fetch:(nullable id)sender;
- (NSFetchRequest *)defaultFetchRequest;
- (BOOL)fetchWithRequest:(nullable NSFetchRequest *)fetchRequest merge:(BOOL)merge error:(NSError **)error;

@end

@interface RNDObjectController (RNDObjectControllerBindings)


@end

@interface RNDSelection:NSProxy { }

- (instancetype)init;

@end


NS_ASSUME_NONNULL_END



