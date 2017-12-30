//
//  RNDAggregationProcessor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 12/26/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindingProcessor.h"

@interface RNDAggregationProcessor: RNDBindingProcessor

@property (readwrite) BOOL filtersNilValues;

@property (readwrite) BOOL filtersMarkerValues;

@property (readwrite) BOOL unwrapSingleValue;

@property (readwrite) BOOL mutuallyExclusive;

@end
