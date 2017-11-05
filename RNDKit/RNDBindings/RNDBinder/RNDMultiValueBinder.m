//
//  RNDMultiValueBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValueBinder.h"
#import "RNDBinding.h"

@interface RNDMultiValueBinder ()

@property (strong, nullable, readonly) NSValueTransformer *valueTransformer;
@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@end

@implementation RNDMultiValueBinder

#pragma mark - Properties

@synthesize andedValue = _andedValue;
@synthesize valueTransformer = _valueTransformer;
@synthesize serializerQueue = _serializerQueue;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            objectValue = nil;
        }
        
        id rawObjectValue = nil;
        
        for (RNDBinding *binding in self.bindings) {
            rawObjectValue = binding.bindingObjectValue;
            
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
                objectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder : rawObjectValue;
                return;
            }
        }
        
        BOOL result =  _andedValue ? YES : NO;
        for (RNDBinding * binding in self.bindings) {
            result = _andedValue ? result && binding.valueAsBool : result || binding.valueAsBool;
        }
        
        NSNumber *resultObjectValue = [NSNumber numberWithBool:result];
        
        
        id transformedObjectValue = nil;
        transformedObjectValue = _valueTransformer != nil ? [_valueTransformer transformedValue:resultObjectValue] : resultObjectValue;
        
        if (transformedObjectValue == nil && self.nullPlaceholder != nil) {
            objectValue = self.nullPlaceholder;
            return;
        } else {
            objectValue = transformedObjectValue;
            return;
        }
    });
    
    return objectValue;
}

#pragma mark - Object Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) == nil) {
        return nil;
    }
    
    _andedValue = [aDecoder decodeBoolForKey:@"andedValue"];
    _serializerQueueIdentifier = [[NSUUID alloc] init];
    _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);
    _valueTransformer = self.valueTransformerName != nil ? [NSValueTransformer valueTransformerForName:self.valueTransformerName] : nil;

    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:_andedValue forKey:@"andedValue"];
}

#pragma mark - Binding Management



#pragma mark - Value Management

- (id)logicalValue:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    __block BOOL result =  _andedValue ? YES : NO;
    dispatch_sync(self.syncQueue, ^{
        for (RNDBinding * binding in self.bindings) {
            result = _andedValue ? result && binding.valueAsBool : result || binding.valueAsBool;
        }
    });
    
    return [NSNumber numberWithBool:result];
}

@end
