//
//  RNDBinderSet.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/27/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"

/*
 TODO: Figure this out
 
 
 The basic idea is:
 1. Return the requested archive to the sender if available.
 2. Get binder manifest if not already loaded
 3. Find the binding set with the VC ID.
 4. Load the set if not already loaded.
 5. Return the requested archive to the sender if available.
 
 Should the binder set class store the archives (loaded) and manifests? In the event of low memory, it should purge the archives which can be reconstituted on demand.
 
 When initialized at runtime, the class will load a default set. As there can be multiple manifest, each one is namespaced, as are all binding ids
 */


@interface RNDBinderSet: NSObject <NSCoding>

@property(nullable, readwrite) NSString *binderSetIdentifier;
@property(nullable, readwrite) NSString *binderSetNamespace;
@property(nonnull, readonly) NSMutableDictionary<NSString *, RNDBinder *> *binders;

@property (strong, readonly, nonnull) NSMutableArray<NSString *> *protocolIdentifiers;

#pragma mark - Object Lifecycle
- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aCoder NS_DESIGNATED_INITIALIZER;

+ (instancetype _Nullable)unarchiveBinderSetAtURL:(NSURL * _Nonnull)url
                                            error:(NSError * __autoreleasing _Nullable * _Nullable)error;

+ (instancetype _Nullable)unarchiveBinderSetWithID:(NSString * _Nonnull)binderSetIdentifier
                                         namespace:(NSString * _Nullable)binderSetNamespace
                                             error:(NSError * __autoreleasing _Nullable * _Nullable)error;

+ (instancetype _Nullable)binderSetWithName:(NSString * _Nonnull)binderSetName;

- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

- (BOOL)archiveBinderSetToURL:(NSURL * _Nonnull)directory
                        error:(NSError * __autoreleasing _Nullable * _Nullable)error;

- (BOOL)archiveBinderSet:(NSError * __autoreleasing _Nullable * _Nullable)error;

@end

