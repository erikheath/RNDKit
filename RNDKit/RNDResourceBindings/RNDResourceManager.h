//
//  RNDResourceManager.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/28/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RNDResourceManager: NSObject

@property (strong, nonnull, readonly) NSDictionary *mergedManifest;
@property (strong, nonnull, readonly) NSMutableDictionary<RNDBinderManifestKey, NSMutableDictionary<RNDBinderSetKey, RNDBinderSet *> *> *resources;

+ (RNDResourceManager * _Nonnull)resourceManager;

@end
