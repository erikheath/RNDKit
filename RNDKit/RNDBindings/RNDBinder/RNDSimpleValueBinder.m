//
//  RNDSimpleValueBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//


#import "RNDSimpleValueBinder.h"
#import "RNDBinding.h"

@interface RNDSimpleValueBinder()

@property (strong, nullable, readonly) NSValueTransformer *valueTransformer;
@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@end

@implementation RNDSimpleValueBinder

@synthesize valueTransformer = _valueTransformer;
@synthesize serializerQueue = _serializerQueue;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;

#pragma mark - Properties
- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            objectValue = nil;
        }
        
        id rawObjectValue = self.bindings.firstObject.bindingObjectValue;
        
        if (rawObjectValue == nil || [rawObjectValue isEqual:[NSNull null]]) { return; }
        
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
        
        id transformedObjectValue = nil;
        transformedObjectValue = _valueTransformer != nil ? [_valueTransformer transformedValue:rawObjectValue] : rawObjectValue;
        
        if (transformedObjectValue == nil && self.nullPlaceholder != nil) {
            objectValue = self.nullPlaceholder;
            return;
        } else {
            objectValue = transformedObjectValue;
            return;
        }
    });
    
    return objectValue != nil ? objectValue : [NSNull null];
}

- (void)setBindingObjectValue:(id)bindingObjectValue {
    dispatch_async(_serializerQueue, ^{
        // There may be no actual change, in which case nothing needs to happen.
        id objectValue = bindingObjectValue == nil ? [NSNull null] : bindingObjectValue;
        if ([self.bindingObjectValue isEqual:objectValue]) { return; }
        dispatch_barrier_async(self.syncQueue, ^{
            id transformedValue = nil;
            if(_valueTransformer != nil && [[_valueTransformer class] allowsReverseTransformation] == YES) {
                transformedValue = [_valueTransformer reverseTransformedValue:objectValue];
            } else {
                transformedValue = objectValue;
            }
            
            // In some cases, a different value on screen may not actually be a different value in the model.
            // This happens when part of the model record is split up into multiple parts.
            if ([self.bindings.firstObject.bindingObjectValue isEqual:transformedValue] == YES) {
                return;
            }
            
            [self.bindings.firstObject setBindingObjectValue:transformedValue];
        });
    });
}



#pragma mark - Object Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) == nil) {
        return nil;
    }
    
    _serializerQueueIdentifier = [[NSUUID alloc] init];
    _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);
    _valueTransformer = self.valueTransformerName != nil ? [NSValueTransformer valueTransformerForName:self.valueTransformerName] : nil;
    
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    return;
}

#pragma mark - Binding Management

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    
    if (context == NULL || context == nil) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    } else if ([(__bridge NSString * _Nonnull)(context) isKindOfClass: [NSString class]] == NO || [(__bridge NSString * _Nonnull)(context) isEqualToString:self.binderIdentifier] == NO) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if (change[NSKeyValueChangeNotificationIsPriorKey] != nil) {
        // Add delegate calls?
    } else {
        // Add delegate calls?
        
        [self updateValueOfObservedObject];
        
    }
    
}

- (void)updateValueOfObservedObject {
    dispatch_barrier_async(self.syncQueue, ^{
        __block id observerObjectValue = nil;
        if (self.observerKey == nil) {
            // This is a value binding.
            dispatch_sync(dispatch_get_main_queue(), ^{
                observerObjectValue = [self.observer bindingObjectValue];
            });
        } else {
            // This is a property binding.
            dispatch_sync(dispatch_get_main_queue(), ^{
                observerObjectValue = [self.observer valueForKeyPath:self.observerKey];
            });
        }
        
        id transformedValue = nil;
        if(_valueTransformer != nil && [[_valueTransformer class] allowsReverseTransformation] == YES) {
            transformedValue = [_valueTransformer reverseTransformedValue:observerObjectValue];
        } else {
            transformedValue = observerObjectValue;
        }
        
        if ([self.bindings.firstObject.bindingObjectValue isEqual:transformedValue] == YES) { return; }
        
        [self.bindings.firstObject setBindingObjectValue:transformedValue];
    });
}



@end

