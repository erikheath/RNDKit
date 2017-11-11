//
//  RNDStaticValueBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/9/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDReferenceValueBinding.h"

@interface RNDReferenceValueBinding()
@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;
@property (strong, nullable, readonly) NSValueTransformer *valueTransformer;
@end


@implementation RNDReferenceValueBinding

#pragma mark - Properties
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize serializerQueue = _serializerQueue;
@synthesize referenceValue = _referenceValue;
@synthesize valueTransformer = _valueTransformer;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        id rawObjectValue = _referenceValue;
        
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
    
    return objectValue;
}

#pragma mark - Object Lifecycle
- (instancetype)init {
    return [self initWithCoder:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _referenceValue = [aDecoder decodeObjectForKey:@"referenceValue"];
        _serializerQueueIdentifier = [[NSUUID alloc] init];
        _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);
        
        if (self.valueTransformerName != nil) {
            _valueTransformer = [NSValueTransformer valueTransformerForName:self.valueTransformerName];
        }

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (aCoder == nil) { return; }
    [aCoder encodeObject:_referenceValue forKey:@"referenceValue"];
}

@end
