//
//  RNDMultiValuePatternedBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"

@class RNDPatternedBinding;

@interface RNDMultiValueBinder : RNDBinder

@property (strong, nonnull, readonly) NSArray<RNDPatternedBinding *> *userStrings;
@property (readonly) BOOL filtersNilValues;
@property (readonly) BOOL filtersMarkerValues;

@end
