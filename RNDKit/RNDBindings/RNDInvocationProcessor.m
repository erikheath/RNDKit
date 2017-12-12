//
//  RNDInvocationBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/4/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDInvocationProcessor.h"
#import "RNDBinder.h"
#import "RNDPredicateProcessor.h"
#import "NSObject+RNDObjectBinding.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVKit/AVKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>


@implementation RNDInvocationProcessor

#pragma mark - Properties
@synthesize bindingSelectorString = _bindingSelectorString;

- (void)setBindingSelectorString:(NSString * _Nullable)bindingSelectorString {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _bindingSelectorString = bindingSelectorString;
    });
}

- (NSString * _Nullable)bindingSelectorString {
    NSString __block *localObject;
    dispatch_sync(self.syncQueue, ^{
        localObject = _bindingSelectorString;
    });
    return localObject;
}

- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            objectValue = nil;
            return;
        }
        
        if (((NSNumber *)self.observedObjectEvaluator.bindingObjectValue).boolValue == NO ) {
            objectValue = nil;
            return;
        }
        
        NSInvocation * __block invocation = [NSInvocation invocationWithMethodSignature: [NSObject methodSignatureForSelector:NSSelectorFromString(_bindingSelectorString)]];
        if (invocation != nil && self.observedObjectBindingValue != nil) {
            [invocation retainArguments];
            [invocation setSelector:NSSelectorFromString(_bindingSelectorString)];
            [invocation setTarget:self.observedObjectBindingValue];

            [self.processorArguments enumerateObjectsUsingBlock:^(RNDBindingProcessor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                RNDBindingProcessor *binding = obj;
                BOOL result = [self addBindingArgumentValue:binding.bindingObjectValue toInvocation:invocation atPosition:idx + 2];
                if (result == NO) {
                    // There was an error. The invocation will be nil'd and the process will end.
                    invocation = nil;
                    *stop = YES;
                    return;
                }
            }];
        }
        
        if (self.processorOutputType == RNDCalculatedValueOutputType) {
            [invocation invoke];
            id result = [self objectValueForInvocation:invocation];
            if ([result isEqual: RNDBindingMultipleValuesMarker] == YES) {
                objectValue = self.multipleSelectionPlaceholder != nil ? self.multipleSelectionPlaceholder.bindingObjectValue : RNDBindingMultipleValuesMarker;
                return;
            }
            
            if ([result isEqual: RNDBindingNoSelectionMarker] == YES) {
                objectValue = self.noSelectionPlaceholder != nil ? self.noSelectionPlaceholder.bindingObjectValue : RNDBindingNoSelectionMarker;
                return;
            }
            
            if ([result isEqual: RNDBindingNotApplicableMarker] == YES) {
                objectValue = self.notApplicablePlaceholder != nil ? self.notApplicablePlaceholder.bindingObjectValue : RNDBindingNotApplicableMarker;
                return;
            }
            
            if ([result isEqual: RNDBindingNullValueMarker] == YES) {
                objectValue = self.nullPlaceholder != nil ? self.nullPlaceholder.bindingObjectValue : RNDBindingNullValueMarker;
                return;
            }
            
            if (result == nil) {
                objectValue = self.nilPlaceholder != nil ? self.nilPlaceholder.bindingObjectValue : result;
                return;
            }

            objectValue = self.valueTransformer != nil ? [self.valueTransformer transformedValue:result] : result;

        } else {
            objectValue = invocation;
        }

    });
    
    return objectValue;
}

#pragma mark - Object Lifecycle
- (instancetype)init {
    return [super init];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) != nil) {
        _bindingSelectorString = [aDecoder decodeObjectForKey:@"bindingSelectorString"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_bindingSelectorString forKey:@"bindingSelectorString"];
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


- (id)objectValueForInvocation:(NSInvocation *)invocation {
    const char *argumentType = invocation.methodSignature.methodReturnType;
    if (strcmp(argumentType, "c") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        char *buffer = (char *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithChar:*buffer];
    } else if (strcmp(argumentType, "i") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        int *buffer = (int *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithInt:*buffer];
    } else if (strcmp(argumentType, "s") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        short *buffer = (short *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithShort:*buffer];
    } else if (strcmp(argumentType, "l") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        long *buffer = (long *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithLong:*buffer];
    } else if (strcmp(argumentType, "q") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        long long *buffer = (long long *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithLongLong:*buffer];
    } else if (strcmp(argumentType, "C") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        unsigned char *buffer = (unsigned char *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithUnsignedChar:*buffer];
    } else if (strcmp(argumentType, "I") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        unsigned int *buffer = (unsigned int *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithUnsignedInt:*buffer];
    } else if (strcmp(argumentType, "S") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        unsigned short *buffer = (unsigned short *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithUnsignedShort:*buffer];
    } else if (strcmp(argumentType, "L") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        unsigned long *buffer = (unsigned long *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithUnsignedLong:*buffer];
    } else if (strcmp(argumentType, "Q") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        unsigned long long *buffer = (unsigned long long *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithUnsignedLongLong:*buffer];
    } else if (strcmp(argumentType, "f") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        float *buffer = (float *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithFloat:*buffer];
    } else if (strcmp(argumentType, "d") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        double *buffer = (double *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithDouble:*buffer];
    } else if (strcmp(argumentType, "B") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        BOOL *buffer = (BOOL *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSNumber numberWithBool:*buffer];
    } else if (strcmp(argumentType, "*") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        char *buffer = (char *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSString stringWithCString:buffer encoding:[NSString defaultCStringEncoding]];
    } else if (strcmp(argumentType, "@") == 0) {
        id buffer;
        [invocation getReturnValue:&buffer];
        return buffer;
    } else if (strcmp(argumentType, "#") == 0) {
        Class buffer;
        [invocation getReturnValue:&buffer];
        return buffer;
    } else if (strcmp(argumentType, ":") == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        SEL *buffer = (SEL *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSValue valueWithPointer:buffer];
    } else if (strncmp(argumentType, "[", 1) == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        void *buffer = (void *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSValue valueWithPointer:buffer];
    } else if (strncmp(argumentType, "{", 1) == 0) {
        // This is a structure argument that must be
        // of one of the supported types.
        if (strncmp(argumentType, "{NSRange", 8)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            NSRange *buffer = (NSRange *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithRange:*buffer];
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
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            CGPoint *buffer = (CGPoint *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithCGPoint:*buffer];
        } else if (strncmp(argumentType, "{CGVector", 9)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            CGVector *buffer = (CGVector *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithCGVector:*buffer];
        } else if (strncmp(argumentType, "{CGSize", 7)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            CGSize *buffer = (CGSize *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithCGSize:*buffer];
        } else if (strncmp(argumentType, "{CGRect", 7)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            CGRect *buffer = (CGRect *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithCGRect:*buffer];
        } else if (strncmp(argumentType, "{CGAffineTransform", 18)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            CGAffineTransform *buffer = (CGAffineTransform *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithCGAffineTransform:*buffer];
        } else if (strncmp(argumentType, "{UIEdgeInsets", 13)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            UIEdgeInsets *buffer = (UIEdgeInsets *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithUIEdgeInsets:*buffer];
        } else if (strncmp(argumentType, "{UIOffset", 9)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            UIOffset *buffer = (UIOffset *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithUIOffset:*buffer];
        } else if (strncmp(argumentType, "{CATransform3D", 14)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            CATransform3D *buffer = (CATransform3D *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithCATransform3D:*buffer];
        } else if (strncmp(argumentType, "{CMTime", 7)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            CMTime *buffer = (CMTime *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithCMTime:*buffer];
        } else if (strncmp(argumentType, "{CMTimeRange", 12)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            CMTimeRange *buffer = (CMTimeRange *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithCMTimeRange:*buffer];
        } else if (strncmp(argumentType, "{CMTimeMapping", 14)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            CMTimeMapping *buffer = (CMTimeMapping *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithCMTimeMapping:*buffer];
        } else if (strncmp(argumentType, "{CLLocationCoordinate2D", 13)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            CLLocationCoordinate2D *buffer = (CLLocationCoordinate2D *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithMKCoordinate:*buffer];
        } else if (strncmp(argumentType, "{MKCoordinateSpan", 17)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            MKCoordinateSpan *buffer = (MKCoordinateSpan *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithMKCoordinateSpan:*buffer];
        } else if (strncmp(argumentType, "{SCNVector3", 11)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            SCNVector3 *buffer = (SCNVector3 *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithSCNVector3:*buffer];
        } else if (strncmp(argumentType, "{SCNVector4", 11)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            SCNVector4 *buffer = (SCNVector4 *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithSCNVector4:*buffer];
        } else if (strncmp(argumentType, "{SCNMatrix4", 11)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            SCNMatrix4 *buffer = (SCNMatrix4 *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithSCNMatrix4:*buffer];
        } else if (strncmp(argumentType, "{NSDirectionalEdgeInsets", 24)) {
            NSUInteger length = invocation.methodSignature.methodReturnLength;
            NSDirectionalEdgeInsets *buffer = (NSDirectionalEdgeInsets *)malloc(length);
            [invocation getReturnValue:buffer];
            return [NSValue valueWithDirectionalEdgeInsets:*buffer];
        } else if (strncmp(argumentType, "{NSEdgeInsets", 13)) {
            //            NSEdgeInsets bindingValue = argumentValue.NSEdgeInsetsValue;
            //            [invocation setArgument:&bindingValue atIndex:position];
        }
    } else if (strncmp(argumentType, "(", 1) == 0) {
        //
    } else if (strncmp(argumentType, "b", 1) == 0) {
        //
    } else if (strncmp(argumentType, "^", 1) == 0) {
        NSUInteger length = invocation.methodSignature.methodReturnLength;
        void *buffer = (void *)malloc(length);
        [invocation getReturnValue:buffer];
        return [NSValue valueWithPointer:buffer];
    } else if (strcmp(argumentType, "?") == 0) {
        //
    }
    return nil;
}

#pragma mark - Binding Management
-(BOOL)bindObjects:(NSError * _Nullable __autoreleasing *)error {
    if (_bindingSelectorString == nil) {
        return NO;
    }
    return [super bindObjects:error];
}

@end

