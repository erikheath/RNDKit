//
//  RNDPredicateBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/9/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinding.h"

@interface RNDPredicateBinding: RNDBinding

@property (strong, readonly, nonnull) NSString *predicateFormatString;

@end
