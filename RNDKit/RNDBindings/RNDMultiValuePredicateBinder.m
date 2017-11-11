//
//  RNDMultiValuePredicateBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValuePredicateBinder.h"
#import "RNDBinding.h"

@interface RNDMultiValuePredicateBinder ()

@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@end

@implementation RNDMultiValuePredicateBinder

#pragma mark - Properties
@synthesize serializerQueue = _serializerQueue;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize filtersNilValues = _filtersNilValues;
@synthesize filtersNonPredicateValues = _filtersNonPredicateValues;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            objectValue = self.nullPlaceholder == nil ? nil : self.nullPlaceholder;
            return;
        }
        
        NSMutableArray *predicateArray = [NSMutableArray arrayWithCapacity:_predicates.count];
        
        [_predicates enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id rawObjectValue = ((RNDBinding *)obj).bindingObjectValue;
            NSString *entryString = _userStrings[idx] == [NSNull null] ? [NSString stringWithFormat:@"Entry %lu", (unsigned long)idx] : _userStrings[idx];
            
            if ([rawObjectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                if (_filtersNonPredicateValues == YES) { return; }
                rawObjectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                if (_filtersNonPredicateValues == YES) { return; }
                rawObjectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                if (_filtersNonPredicateValues == YES) { return; }
                rawObjectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder : rawObjectValue;
            }
            
            if (rawObjectValue == nil) {
                if (_filtersNonPredicateValues == YES || _filtersNilValues == YES) { return; }
                rawObjectValue = self.nullPlaceholder != nil ? self.nullPlaceholder : [NSNull null];
            }
            
            [predicateArray addObject:@{entryString: rawObjectValue}];
            
        }];
         
         objectValue = predicateArray;
        
    });
    
    return objectValue;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) == nil) {
        return nil;
    }
    
    _serializerQueueIdentifier = [[NSUUID alloc] init];
    _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);
    
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

}

#pragma mark - Binding Management



#pragma mark - Value Management


@end
