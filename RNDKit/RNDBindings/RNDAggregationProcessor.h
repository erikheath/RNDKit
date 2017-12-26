//
//  RNDAggregationProcessor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 12/26/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindingProcessor.h"

typedef NS_ENUM(NSUInteger, RNDValueMode) {
    RNDValueOnlyMode,
    RNDKeyedValueMode,
    RNDOrderedKeyedValueMode
};

@interface RNDAggregationProcessor: RNDBindingProcessor

@property (readwrite) RNDValueMode valueMode;

@property (nonnull, strong, readonly) NSMutableArray<RNDBindingProcessor *> *inflowProcessors;

@property (strong, nullable, readonly) NSArray<RNDBindingProcessor *> *boundInflowProcessors;

@property (nonnull, strong, readonly) NSMutableArray<RNDBindingProcessor *> *outflowProcessors;

@property (nonnull, strong, readonly) NSArray<RNDBindingProcessor *> *boundOutflowProcessors;

@property (readwrite) BOOL filtersNilValues;

@property (readwrite) BOOL filtersMarkerValues;

@property (readwrite) BOOL unwrapSingleValue;

@property (readwrite) BOOL mutuallyExclusive;

@end
