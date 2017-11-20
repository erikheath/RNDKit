//
//  RNDMultiValuePatternedBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValuePatternedBinder.h"
#import "RNDBinding.h"
#import "RNDPatternedBinding.h"

@interface RNDMultiValuePatternedBinder ()

@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@end

@implementation RNDMultiValuePatternedBinder

#pragma mark - Properties
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize serializerQueue = _serializerQueue;
@synthesize userStrings = _userStrings;
@synthesize patternedStrings = _patternedStrings;
@synthesize filtersNilValues = _filtersNilValues;
@synthesize filtersNonPatternValues = _filtersNonPatternValues;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        if (self.isBound == NO) {
            objectValue = nil;
        }
        
        NSMutableArray *patternedStringArray = [NSMutableArray arrayWithCapacity:_patternedStrings.count];
        
        [_patternedStrings enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id rawObjectValue = ((RNDBinding *)obj).bindingObjectValue;
            NSString *entryString = _userStrings[idx].bindingObjectValue == nil ? [NSString stringWithFormat:@"Entry %lu", (unsigned long)idx] : _userStrings[idx].bindingObjectValue;
            
            if ([rawObjectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                if (_filtersNonPatternValues == YES) { return; }
                rawObjectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                if (_filtersNonPatternValues == YES) { return; }
                rawObjectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                if (_filtersNonPatternValues == YES) { return; }
                rawObjectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder : rawObjectValue;
            }
            
            if (rawObjectValue == nil) {
                if (_filtersNonPatternValues == YES || _filtersNilValues == YES) { return; }
                rawObjectValue = self.nullPlaceholder != nil ? self.nullPlaceholder : [NSNull null];
            }
            
            [patternedStringArray addObject:@{entryString: rawObjectValue}];
            
        }];
        
        objectValue = patternedStringArray;
    });
    
    return objectValue;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) == nil) {
        return nil;
    }
    _patternedStrings = [aDecoder decodeObjectForKey:@"patternedStrings"];
    _serializerQueueIdentifier = [[NSUUID alloc] init];
    _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);

    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_patternedStrings forKey:@"patternedStrings"];
}

#pragma mark - Binding Management




@end
