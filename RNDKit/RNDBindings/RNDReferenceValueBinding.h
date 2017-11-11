//
//  RNDStaticValueBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/9/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinding.h"

@interface RNDReferenceValueBinding: RNDBinding

@property(strong, readonly, nonnull) id referenceValue;

@end

