//
//  RNDBinderSetInfo.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/27/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

// This class reads in the data from a binderset plist with the
// specified identifier and constructs a binderset info object.
// The object can be used to create a new binderset with the
// defaults of the binding identifier.

#import <Foundation/Foundation.h>
#import "../RNDBinder/RNDMutableBinderSet.h"

@interface RNDBinderSetInfo: NSObject

@property(nonnull, readonly) NSString *binderSetInfoIdentifier;
@property(nonnull, readonly) NSDictionary *binderInfo;

// Calls the designated initializer.
+ (instancetype)binderSetInfoForIdentifier:(NSString * _Nonnull)binderSetInfoIdentifier;

// Reads in the binder set info from its associated plist.
- (instancetype)initWithIdentifier:(NSString * _Nonnull)binderSetIdentifier;

// Produces a mutable binder set from the info contained in the plist corresponding
// to the binding set info identifier.
+ (RNDMutableBinderSet * _Nullable)defaultMutableBinderSetForIdentifer:(NSString * _Nonnull)binderSetInfoIdentifier;

// Convenience method that produces a mutable binder set by merging the info contained
// in an archived instance on disk of a binder set with the default instance returned by
// defaultMutableBinderSetForIdentifier.
+ (RNDMutableBinderSet * _Nullable)mergedMutableBinderSetForIdentifier:(NSString * _Nonnull)binderSetIdentifer;

@end
