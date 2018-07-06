//
//  RNDMutableProcessor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 6/30/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDProcessor.h"

@interface RNDMutableProcessor : RNDProcessor

@property (readwrite) BOOL processConcurrently;
@property (readwrite) BOOL processInReverseOrder;
@property (strong, readonly) NSMutableArray<NSDictionary <NSString *, NSString *> *> *directives;


/**
 Adds a directive to the end of the directives array.
 
 @param directive The directive to be added.

 */
- (void)addObject:(NSDictionary<NSString *, NSString *> *)directive;


@end
