//
//  RNDMultiValuePatternedBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValueBinder.h"
#import "RNDBinding.h"
#import "RNDPatternedBinding.h"

@interface RNDMultiValueBinder ()

@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@end

@implementation RNDMultiValueBinder

#pragma mark - Properties
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize serializerQueue = _serializerQueue;
@synthesize userStrings = _userStrings;
@synthesize filtersNilValues = _filtersNilValues;
@synthesize filtersMarkerValues = _filtersMarkerValues;
@synthesize binderValue = _binderValue;


- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        if (self.isBound == NO) {
            objectValue = nil;
        }
        
        NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:_binderValue.count];
        
        [_binderValue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id rawObjectValue = ((RNDBinding *)obj).bindingObjectValue;
            NSString *entryString = _userStrings[idx].bindingObjectValue == nil ? [NSString stringWithFormat:@"Entry %lu", (unsigned long)idx] : _userStrings[idx].bindingObjectValue;
            
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
            
            [valuesArray addObject:@{entryString: rawObjectValue}];
            
        }];
        
        objectValue = valuesArray;
    });
    
    return objectValue;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) == nil) {
        return nil;
    }
    _binderValue = [aDecoder decodeObjectForKey:@"binderValue"];
    _userStrings = [aDecoder decodeObjectForKey:@"userStrings"];
    _filtersMarkerValues = [aDecoder decodeBoolForKey:@"filtersNonTypeValues"];
    _filtersNilValues = [aDecoder decodeBoolForKey:@"filtersNilValues"];
    _serializerQueueIdentifier = [[NSUUID alloc] init];
    _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);

    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_binderValue forKey:@"binderValue"];
    [aCoder encodeObject:_userStrings forKey:@"userStrings"];
    [aCoder encodeBool:_filtersNilValues forKey:@"filtersNilValues"];
    [aCoder encodeBool:_filtersMarkerValues forKey:@"filtersNonTypeValues"];

}

#pragma mark - Binding Management




@end
