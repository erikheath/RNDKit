//
//  RNDMultiValueRegExBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValueRegExBinder.h"
#import "RNDBinding.h"
#import "RNDRegExBinding.h"
#import "RNDPatternedBinding.h"

@interface RNDMultiValueRegExBinder ()

@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@end

@implementation RNDMultiValueRegExBinder

#pragma mark - Properties
@synthesize serializerQueue = _serializerQueue;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize filtersNilValues = _filtersNilValues;
@synthesize filtersNonRegExValues = _filtersNonRegExValues;
@synthesize regularExpressions = _regularExpressions;
@synthesize userStrings = _userStrings;
@synthesize keyedRegularExpressions = _keyedRegularExpressions;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            objectValue = self.nullPlaceholder == nil ? nil : self.nullPlaceholder;
            return;
        }
        
        NSMutableArray *regExArray = [NSMutableArray arrayWithCapacity:_regularExpressions.count];
        
        [_regularExpressions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id rawObjectValue = ((RNDBinding *)obj).bindingObjectValue;
            NSString *entryString = _userStrings[idx].bindingObjectValue == [NSNull null] ? [NSString stringWithFormat:@"Entry %lu", (unsigned long)idx] : _userStrings[idx].bindingObjectValue;
            
            if ([rawObjectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                if (_filtersNonRegExValues == YES) { return; }
                rawObjectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                if (_filtersNonRegExValues == YES) { return; }
                rawObjectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder : rawObjectValue;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                if (_filtersNonRegExValues == YES) { return; }
                rawObjectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder : rawObjectValue;
            }
            
            if (rawObjectValue == nil) {
                if (_filtersNonRegExValues == YES || _filtersNilValues == YES) { return; }
                rawObjectValue = self.nullPlaceholder != nil ? self.nullPlaceholder : [NSNull null];
            }
            
            [regExArray addObject:@{entryString: rawObjectValue}];
            
        }];
         
         objectValue = regExArray;
        
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
