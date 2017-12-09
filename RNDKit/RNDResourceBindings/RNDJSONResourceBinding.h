//
//  RNDJSONResource.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/29/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDResourceBinding.h"

@interface RNDJSONResourceBinding: RNDResourceBinding

@property (readwrite) BOOL mutableContainers;
@property (readwrite) BOOL mutableLeaves;
@property (readwrite) BOOL allowsFragments;

@end
