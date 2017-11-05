//
//  RNDBinderSet.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/27/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

// The mutable variants are used exclusively on the mac for design time construction.
// The binding set has the list of binders available for a specific class.

#import <Foundation/Foundation.h>
#import "../../RNDBindingInfo/RNDBinderSetInfo.h"

@interface RNDMutableBinderSetTemplate: NSObject

@property(nonnull, readwrite) NSString *binderSetIdentifier;
@property(nonnull, readwrite) NSDictionary *binders;

// Factory method that create a new binding set based on the binding set info
+ (instancetype)bindingSetWithInfo:(RNDBinderSetInfo * _Nonnull)info;
- (instancetype)initWithInfo:(RNDBinderSetInfo * _Nonnull)info;
- (instancetype)initWithCoder:(NSCoder *)aCoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
