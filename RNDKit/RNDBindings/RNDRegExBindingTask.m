//
//  RNDExpressionBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDRegExBindingTask.h"

@interface RNDRegExBindingTask()

@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;
@property (strong, nonnull, readonly) NSString *evaluatedObjectBindingIdentifier;

@end

@implementation RNDRegExBindingTask

#pragma mark - Properties
@synthesize expression = _expression;
@synthesize replacementTemplate = _replacementTemplate;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize serializerQueue = _serializerQueue;
@synthesize evaluatedObjectBindingIdentifier = _evaluatedObjectBindingIdentifier;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(_serializerQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        id rawObjectValue = [self.observedObject valueForKey:self.observedObjectKeyPath];
        
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
        
        if (transformedObjectValue == nil) {
            if (self.nullPlaceholder != nil) {
                objectValue = self.nullPlaceholder;
            } else {
                objectValue = transformedObjectValue;
            }
            return;
        }
        
        NSString *expressionValue = [_expression stringByReplacingMatchesInString:transformedObjectValue
                                                                          options:0
                                                                            range:NSMakeRange(0, ((NSString *)transformedObjectValue).length)
                                                                     withTemplate:_replacementTemplate];
        objectValue = expressionValue;
    });
    
    return objectValue;
}

- (void)setBindingObjectValue:(id)bindingObjectValue {
    return;
}

#pragma mark - Object Lifecycle
- (instancetype)init {
    return [self initWithCoder:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _expression = [aDecoder decodeObjectForKey:@"expression"];
        _replacementTemplate = [aDecoder decodeObjectForKey:@"replacementTemplate"];
        _serializerQueueIdentifier = [[NSUUID alloc] init];
        _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);
        if (self.valueTransformerName != nil) {
            _valueTransformer = [NSValueTransformer valueTransformerForName:self.valueTransformerName];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_expression forKey:@"expression"];
    [aCoder encodeObject:_replacementTemplate forKey:@"replacementTemplate"];
}

#pragma mark - Binding Management

@end
