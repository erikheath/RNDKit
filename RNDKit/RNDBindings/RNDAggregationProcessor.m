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

@synthesize valueMode = _valueMode;

- (void)setValueMode:(RNDValueMode)valueMode {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _valueMode = valueMode;
    });
}

- (RNDValueMode)valueMode {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _valueMode;
    });
    return localObject;
}


@synthesize filtersNilValues = _filtersNilValues;

- (void)setFiltersNilValues:(BOOL)filtersNilValues {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _filtersNilValues = filtersNilValues;
    });
}

- (BOOL)filtersNilValues {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _filtersNilValues;
    });
    return localObject;
}


@synthesize filtersMarkerValues = _filtersMarkerValues;

- (void)setFiltersMarkerValues:(BOOL)filtersMarkerValues {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _filtersMarkerValues = filtersMarkerValues;
    });
}

- (BOOL)filtersMarkerValues {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _filtersMarkerValues;
    });
    return localObject;
}


@synthesize mutuallyExclusive = _mutuallyExclusive;

- (void)setMutuallyExclusive:(BOOL)mutuallyExclusive {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _mutuallyExclusive = mutuallyExclusive;
    });
}

- (BOOL)mutuallyExclusive {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _mutuallyExclusive;
    });
    return localObject;
}


@synthesize unwrapSingleValue = _unwrapSingleValue;

- (void)setUnwrapSingleValue:(BOOL)unwrapSingleValue {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _unwrapSingleValue = unwrapSingleValue;
    });
}

- (BOOL)unwrapSingleValue {
    BOOL __block localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _unwrapSingleValue;
    });
    return localObject;
}


#pragma mark - Transient (Calculated) Properties
- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        if (self.isBound == NO) {
            objectValue = nil;
            return;
        }
        
        NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:self.boundArguments.count];
        
        [self.boundArguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id rawObjectValue = ((RNDBindingProcessor *)obj).bindingObjectValue;
            if ([rawObjectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                if (_filtersMarkerValues == YES) { return; }
                rawObjectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder.bindingObjectValue : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                if (_filtersMarkerValues == YES) { return; }
                rawObjectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder.bindingObjectValue : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                if (_filtersMarkerValues == YES) { return; }
                rawObjectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder.bindingObjectValue : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNullValueMarker] == YES) {
                if (_filtersMarkerValues == YES) { return; }
                rawObjectValue = self.nullPlaceholder != nil ? self.nullPlaceholder.bindingObjectValue : rawObjectValue;
            }
            
            if (rawObjectValue == nil) {
                if (_filtersMarkerValues == YES || _filtersNilValues == YES) { return; }
                rawObjectValue = self.nilPlaceholder != nil ? self.nilPlaceholder.bindingObjectValue : [NSNull null];
            }
            
            NSString *entryString = ((RNDBindingProcessor *)obj).userString.bindingObjectValue;
            entryString = entryString != nil ? entryString : [NSString stringWithFormat:@"%lu", (unsigned long)idx];
            [valuesArray addObject:@{entryString: rawObjectValue}];
            if (_mutuallyExclusive == YES) { *stop = YES; }
            
        }];
        
        
        switch (_valueMode) {
            case RNDValueOnlyMode:
            {
                NSMutableArray *valueOnlyArray = [NSMutableArray arrayWithCapacity:valuesArray.count];
                for (NSDictionary *dictionary in valuesArray) {
                    [valueOnlyArray addObjectsFromArray:[dictionary allValues]];
                }
                objectValue = _unwrapSingleValue == YES ? (valueOnlyArray.count < 2 ? valueOnlyArray.firstObject : valueOnlyArray) : valueOnlyArray;
                break;
            }
            case RNDKeyedValueMode:
            {
                NSMutableDictionary *keyedValueDictionary = [NSMutableDictionary dictionaryWithCapacity:valuesArray.count];
                for (NSDictionary *dictionary in valuesArray) {
                    [keyedValueDictionary addEntriesFromDictionary:dictionary];
                }
                objectValue = keyedValueDictionary;
                break;
            }
            case RNDOrderedKeyedValueMode:
            {
                objectValue = valuesArray;
                break;
            }
            default:
            {
                objectValue = valuesArray;
                break;
            }
        }
        
    });
    
    return objectValue;
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
        _valueMode = [aDecoder decodeIntForKey:@"valueMode"];
        _filtersNilValues = [aDecoder decodeBoolForKey:@"filtersNilValues"];
        _filtersMarkerValues = [aDecoder decodeBoolForKey:@"filtersMarkerValues"];
        _mutuallyExclusive = [aDecoder decodeBoolForKey:@"mutuallyExclusive"];
        _unwrapSingleValue = [aDecoder decodeBoolForKey:@"unwrapSingleValue"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (aCoder == nil) { return; }
    [aCoder encodeInt:_valueMode forKey:@"valueMode"];
    [aCoder encodeBool:_filtersNilValues forKey:@"filtersNilValues"];
    [aCoder encodeBool:_filtersMarkerValues forKey:@"filtersMarkerValues"];
    [aCoder encodeBool:_mutuallyExclusive forKey:@"mutuallyExclusive"];
    [aCoder encodeBool:_unwrapSingleValue forKey:@"unwrapSingleValue"];

}


#pragma mark - Binding Management

@end
