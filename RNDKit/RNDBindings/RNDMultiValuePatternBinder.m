//
//  RNDMultiValuePatternBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValuePatternBinder.h"
#import "RNDBinding.h"

@interface RNDMultiValuePatternBinder ()

@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@end

@implementation RNDMultiValuePatternBinder

#pragma mark - Properties
@synthesize patternString = _patternString;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize serializerQueue = _serializerQueue;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        if (self.isBound == NO) {
            objectValue = nil;
        }
        
        NSMutableString *replacableObjectValue = replacableObjectValue = [NSMutableString stringWithString:_patternString];

        for (RNDBinding *binding in self.bindings) {
            
            id rawObjectValue = binding.bindingObjectValue;
                        
            if ([rawObjectValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                objectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder : rawObjectValue;
                return;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                objectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder : rawObjectValue;
                return;
            }
            
            if ([rawObjectValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                objectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder : rawObjectValue;
                return;
            }
            
            if (rawObjectValue == nil) {
                objectValue = self.nullPlaceholder != nil ? self.nullPlaceholder : objectValue;
                return;
            }
            
            [replacableObjectValue replaceOccurrencesOfString:binding.argumentName
                                                   withString:binding.bindingObjectValue
                                                      options:0
                                                        range:NSMakeRange(0, replacableObjectValue.length)];
        }
        
        objectValue = replacableObjectValue;
    });
    
    return objectValue;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) == nil) {
        return nil;
    }

    _patternString = [aDecoder decodeObjectForKey:@"patternString"];
    _serializerQueueIdentifier = [[NSUUID alloc] init];
    _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);

    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_patternString forKey:@"patternString"];
}


#pragma mark - Binding Management




@end
