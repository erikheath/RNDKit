//
//  RNDInvocationBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/4/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDInvocationBinding.h"
#import "RNDBinder.h"
#import "NSObject+RNDObjectBinding.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVKit/AVKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>


@implementation RNDInvocationBinding

#pragma mark - Properties
@synthesize bindingSelector = _bindingSelector;


- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.serializerQueue, ^{
        
        if (self.isBound == NO) {
            return;
        }
        
        NSMutableDictionary *argumentsDictionary = [NSMutableDictionary dictionary];
        for (RNDBinding *binding in self.bindingArguments) {
            id objectValue = binding.bindingObjectValue;
            if (objectValue == nil) { objectValue = [NSNull null];}
            [argumentsDictionary setObject:objectValue forKey:binding.argumentName];
        }
        NSDictionary *contextDictionary = (dispatch_get_context(self.serializerQueue) != NULL ? (__bridge NSDictionary *)(dispatch_get_context(self.serializerQueue)) : nil);
        [argumentsDictionary addEntriesFromDictionary:contextDictionary];
        
        NSInvocation * __block invocation = [NSInvocation invocationWithMethodSignature: [NSObject methodSignatureForSelector:_bindingSelector]];
        if (invocation != nil && self.evaluatedObject != nil) {
            [invocation retainArguments];
            [invocation setSelector:_bindingSelector];
            [invocation setTarget:self.evaluatedObject];

            [self.bindingArguments enumerateObjectsUsingBlock:^(RNDBinding * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                RNDBinding *binding = obj;
                id argumentValue = [argumentsDictionary objectForKey:binding.argumentName];
                
                if ([argumentValue isEqual: RNDBindingMultipleValuesMarker] == YES) {
                    objectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder : RNDBindingMultipleValuesMarker;
                    *stop = YES;
                    return;
                }
                
                if ([argumentValue isEqual: RNDBindingNoSelectionMarker] == YES) {
                    objectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder : RNDBindingNoSelectionMarker;
                    *stop = YES;
                    return;
                }
                
                if ([argumentValue isEqual: RNDBindingNotApplicableMarker] == YES) {
                    objectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder : RNDBindingNotApplicableMarker;
                    *stop = YES;
                    return;
                }
                
                if ([argumentValue isEqual: RNDBindingNullValueMarker] == YES) {
                    objectValue = self.nullPlaceholder != nil ? self.nullPlaceholder : RNDBindingNullValueMarker;
                    *stop = YES;
                    return;
                }
                
                BOOL result = [self addBindingArgumentValue:argumentValue toInvocation:invocation atPosition:idx + 2];
                if (result == NO) {
                    // There was an error. The invocation will be nil'd and the process will end.
                    invocation = nil;
                    *stop = YES;
                    return;
                }
            }];
            
        }

        objectValue = invocation;
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
        _bindingSelector = NSSelectorFromString([aDecoder decodeObjectForKey:@"bindingSelector"]);
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:NSStringFromSelector(_bindingSelector) forKey:@"bindingSelector"];
}

#pragma mark - Binding Management


#pragma mark - Invocation Processing

/**
 This method is used to fill in invocation arguments. It attempts to test the arguments and the expected type of the argument position. If the two match, it will attempt to assign the argument. If the two do not match, it will return a NO value indicating that the invocation should not be used.

 @param argumentValue The value that should be assigned to the parameter
 @param invocation The invocation object that should receive the value assignment
 @param position The position within the method that should receive the value assignment
 @return If the assignment was successful according to the type/value matching rules.
 */
- (BOOL)addBindingArgumentValue:(id)argumentValue
              toInvocation:(NSInvocation *)invocation
                atPosition:(NSUInteger)position {
    const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:position];
    if (strcmp(argumentType, "c") == 0) {
        char bindingValue = [argumentValue charValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "i") == 0) {
        int bindingValue = [argumentValue intValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "s") == 0) {
        short bindingValue = [argumentValue shortValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "l") == 0) {
        long bindingValue = [argumentValue longValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "q") == 0) {
        long long bindingValue = [argumentValue longLongValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "C") == 0) {
        unsigned char bindingValue = [argumentValue unsignedCharValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "I") == 0) {
        unsigned int bindingValue = [argumentValue unsignedIntValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "S") == 0) {
        unsigned short bindingValue = [argumentValue unsignedShortValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "L") == 0) {
        unsigned long bindingValue = [argumentValue unsignedLongValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "Q") == 0) {
        unsigned long long bindingValue = [argumentValue unsignedLongLongValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "f") == 0) {
        float bindingValue = [argumentValue floatValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "d") == 0) {
        double bindingValue = [argumentValue doubleValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "B") == 0) {
        BOOL bindingValue = [argumentValue boolValue];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "*") == 0) {
        const char * bindingValue = [argumentValue cStringUsingEncoding:[NSString defaultCStringEncoding]];
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "@") == 0) {
        id bindingValue = argumentValue;
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, "#") == 0) {
        Class bindingValue = argumentValue;
        [invocation setArgument:&bindingValue atIndex:position];
    } else if (strcmp(argumentType, ":") == 0) {
        SEL *bindingValue = [argumentValue pointerValue];
        [invocation setArgument:bindingValue atIndex:position];
    } else if (strncmp(argumentType, "[", 1) == 0) {
        void *bindingValue = [argumentValue pointerValue];
        [invocation setArgument:bindingValue atIndex:position];
    } else if (strncmp(argumentType, "{", 1) == 0) {
        // This is a structure argument that must be
        // of one of the supported types.
        if ([argumentValue isKindOfClass:[NSValue class]] == NO) {
            return NO;
        }
        if (strncmp(argumentType, "{NSRange", 8)) {
            NSRange bindingValue = [argumentValue rangeValue];
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{NSPoint", 8)) {
//            NSPoint bindingValue = [argumentValue pointValue];
//            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{NSSize", 7)) {
//            NSSize bindingValue = [argumentValue sizeValue];
//            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{NSRect", 7)) {
//            NSRect bindingValue = [argumentValue rectValue];
//            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{CGPoint", 8)) {
            CGPoint bindingValue = ((NSValue *)argumentValue).CGPointValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{CGVector", 9)) {
            CGVector bindingValue = ((NSValue *)argumentValue).CGVectorValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{CGSize", 7)) {
            CGSize bindingValue = ((NSValue *)argumentValue).CGSizeValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{CGRect", 7)) {
            CGRect bindingValue = ((NSValue *)argumentValue).CGRectValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{CGAffineTransform", 18)) {
            CGAffineTransform bindingValue = ((NSValue *)argumentValue).CGAffineTransformValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{UIEdgeInsets", 13)) {
            UIEdgeInsets bindingValue = ((NSValue *)argumentValue).UIEdgeInsetsValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{UIOffset", 9)) {
            UIOffset bindingValue = ((NSValue *)argumentValue).UIOffsetValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{CATransform3D", 14)) {
            CATransform3D bindingValue = ((NSValue *)argumentValue).CATransform3DValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{CMTime", 7)) {
            CMTime bindingValue = ((NSValue *)argumentValue).CMTimeValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{CMTimeRange", 12)) {
            CMTimeRange bindingValue = ((NSValue *)argumentValue).CMTimeRangeValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{CMTimeMapping", 14)) {
            CMTimeMapping bindingValue = ((NSValue *)argumentValue).CMTimeMappingValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{CLLocationCoordinate2D", 13)) {
            CLLocationCoordinate2D bindingValue = ((NSValue *)argumentValue).MKCoordinateValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{MKCoordinateSpan", 17)) {
            MKCoordinateSpan bindingValue = ((NSValue *)argumentValue).MKCoordinateSpanValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{SCNVector3", 11)) {
            SCNVector3 bindingValue = ((NSValue *)argumentValue).SCNVector3Value;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{SCNVector4", 11)) {
            SCNVector4 bindingValue = ((NSValue *)argumentValue).SCNVector4Value;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{SCNMatrix4", 11)) {
            SCNMatrix4 bindingValue = ((NSValue *)argumentValue).SCNMatrix4Value;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{NSDirectionalEdgeInsets", 24)) {
            NSDirectionalEdgeInsets bindingValue = ((NSValue *)argumentValue).directionalEdgeInsetsValue;
            [invocation setArgument:&bindingValue atIndex:position];
        } else if (strncmp(argumentType, "{NSEdgeInsets", 13)) {
            return NO;
//            NSEdgeInsets bindingValue = argumentValue.NSEdgeInsetsValue;
//            [invocation setArgument:&bindingValue atIndex:position];
        }
    } else if (strncmp(argumentType, "(", 1) == 0) {
        return NO;
//
    } else if (strncmp(argumentType, "b", 1) == 0) {
        return NO;
//
    } else if (strncmp(argumentType, "^", 1) == 0) {
        void *bindingValue = [argumentValue pointerValue];
        [invocation setArgument:bindingValue atIndex:position];
    } else if (strcmp(argumentType, "?") == 0) {
        return NO;
//
    }
    return YES;
}

@end

