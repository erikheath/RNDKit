//
//  RNDStaticValueBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/9/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDReferenceValueBinding.h"


@implementation RNDReferenceValueBinding

#pragma mark - Properties
@synthesize referenceValue = _referenceValue;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        id rawObjectValue = _referenceValue;
        
        id transformedObjectValue = nil;
        transformedObjectValue = self.valueTransformer != nil ? [self.valueTransformer transformedValue:rawObjectValue] : rawObjectValue;
        
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

    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (aCoder == nil) { return; }
    [aCoder encodeObject:_referenceValue forKey:@"referenceValue"];
}

@end
