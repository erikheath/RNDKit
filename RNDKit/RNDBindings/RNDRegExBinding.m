//
//  RNDRegExBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDRegExBinding.h"

@interface RNDRegExBinding()

@property (strong, nonnull, readonly) NSUUID *serializerQueueIdentifier;
@property (strong, nonnull, readonly) dispatch_queue_t serializerQueue;

@end

@implementation RNDRegExBinding

#pragma mark - Properties
@synthesize expressionTemplate = _expressionTemplate;
@synthesize serializerQueueIdentifier = _serializerQueueIdentifier;
@synthesize serializerQueue = _serializerQueue;

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(_serializerQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        NSMutableString *replacableObjectValue = [NSMutableString stringWithString:_expressionTemplate];
        
        for (RNDBinding *binding in self.bindingArguments) {
            
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
        
        objectValue = [NSRegularExpression regularExpressionWithPattern:replacableObjectValue options:0 error:nil]; // TODO: Error Handling

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
        _expressionTemplate = [aDecoder decodeObjectForKey:@"expressionTemplate"];
        _serializerQueueIdentifier = [[NSUUID alloc] init];
        _serializerQueue = dispatch_queue_create([[_serializerQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_expressionTemplate forKey:@"expressionTemplate"];
}

#pragma mark - Binding Management

@end
