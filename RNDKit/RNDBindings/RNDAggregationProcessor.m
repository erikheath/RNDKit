//
//  RNDAggregationProcessor.m
//  RNDKit
//
//  Created by Erikheath Thomas on 12/26/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDAggregationProcessor.h"
#import "RNDPatternedStringProcessor.h"
#import <objc/runtime.h>


@implementation RNDAggregationProcessor
#pragma mark - Properties

@synthesize filtersNilValues = _filtersNilValues;

- (void)setFiltersNilValues:(BOOL)filtersNilValues {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _filtersNilValues = filtersNilValues;
    });
}

- (BOOL)filtersNilValues {
    BOOL __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _filtersNilValues;
    });
    return localObject;
}


@synthesize filtersMarkerValues = _filtersMarkerValues;

- (void)setFiltersMarkerValues:(BOOL)filtersMarkerValues {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _filtersMarkerValues = filtersMarkerValues;
    });
}

- (BOOL)filtersMarkerValues {
    BOOL __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _filtersMarkerValues;
    });
    return localObject;
}


@synthesize mutuallyExclusive = _mutuallyExclusive;

- (void)setMutuallyExclusive:(BOOL)mutuallyExclusive {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _mutuallyExclusive = mutuallyExclusive;
    });
}

- (BOOL)mutuallyExclusive {
    BOOL __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _mutuallyExclusive;
    });
    return localObject;
}

#pragma mark - Transient (Calculated) Properties
- (id _Nullable)coordinatedBindingValue {
    dispatch_assert_queue_debug(self.coordinator);

    id __block objectValue = nil;
    
    NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:self.boundProcessorArguments.count];
        
    [self.boundProcessorArguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // Generate the raw value from the current processor
        id aggregationValue = [self rawBindingValue:((RNDBindingProcessor *)obj)];
        
        // Apply calculations to the value
        aggregationValue = [self calculatedBindingValue:aggregationValue];
        
        // Filter the value
        aggregationValue = [self filteredBindingValue:aggregationValue];
        if (aggregationValue == RNDBindingRemoveValueMarker) { return; }
        
        // Transform the value
        aggregationValue = [self transformedBindingValue:aggregationValue];
        
        // Label the value
        NSString *entryString = ((RNDBindingProcessor *)obj).bindingValueLabel.bindingValue;
        entryString = entryString != nil ? entryString : [NSString stringWithFormat:@"%lu", (unsigned long)idx];
        
        // Add the value to the aggregated output
        [valuesArray addObject:@{entryString: aggregationValue}];
        if (_mutuallyExclusive == YES) { *stop = YES; }
        
    }];
    
    // Apply the correct wrapping to the aggregated values.
    objectValue = [self wrappedBindingValue:valuesArray];
    
    return objectValue;
}

- (id _Nullable)rawBindingValue:(id _Nullable)bindingValue {
    return ((RNDBindingProcessor *)bindingValue).bindingValue;
}

- (id _Nullable)filteredBindingValue:(id)bindingValue {
    id objectValue = nil;
    
    if ([bindingValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
        if (_filtersMarkerValues == YES) { return RNDBindingRemoveValueMarker; }
        objectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder.bindingValue : bindingValue;
    }
    
    if ([bindingValue isEqual: RNDBindingNoSelectionMarker] == YES) {
        if (_filtersMarkerValues == YES) { return RNDBindingRemoveValueMarker; }
        objectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder.bindingValue : bindingValue;
    }
    
    if ([bindingValue isEqual: RNDBindingNotApplicableMarker] == YES) {
        if (_filtersMarkerValues == YES) { return RNDBindingRemoveValueMarker; }
        objectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder.bindingValue : bindingValue;
    }
    
    if ([bindingValue isEqual: RNDBindingNullValueMarker] == YES) {
        if (_filtersMarkerValues == YES) { return RNDBindingRemoveValueMarker; }
        objectValue = self.nullPlaceholder != nil ? self.nullPlaceholder.bindingValue : bindingValue;
    }
    
    if (bindingValue == nil) {
        if (_filtersMarkerValues == YES || _filtersNilValues == YES) { return RNDBindingRemoveValueMarker; }
        objectValue = self.nilPlaceholder != nil ? self.nilPlaceholder.bindingValue : [NSNull null];
    }

    objectValue = bindingValue;
    
    return objectValue;
}

- (id _Nullable)transformedBindingValue:(id)bindingValue {
    return bindingValue;
}


#pragma mark - Object Lifecycle

- (instancetype _Nullable)init {
    if ((self = [super init]) != nil) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (aDecoder == nil) {
        return nil;
    }
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _filtersNilValues = [aDecoder decodeBoolForKey:@"filtersNilValues"];
        _filtersMarkerValues = [aDecoder decodeBoolForKey:@"filtersMarkerValues"];
        _mutuallyExclusive = [aDecoder decodeBoolForKey:@"mutuallyExclusive"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (aCoder == nil) { return; }
    [aCoder encodeBool:_filtersNilValues forKey:@"filtersNilValues"];
    [aCoder encodeBool:_filtersMarkerValues forKey:@"filtersMarkerValues"];
    [aCoder encodeBool:_mutuallyExclusive forKey:@"mutuallyExclusive"];

}


#pragma mark - Binding Management

@end
