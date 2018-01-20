//
//  RNDBinderSet.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/27/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

// TODO: Define Implementation

#import "RNDBinderSet.h"
#import "RNDBindings.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVKit/AVKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

@implementation RNDBinderSet

@synthesize binderSetIdentifier = _binderSetIdentifier;
@synthesize binders = _binders;
@synthesize binderSetNamespace = _binderSetNamespace;

#pragma mark - Object Lifecycle
- (instancetype _Nullable)init {
    if ((self = [super init]) != nil) {
        _binders = [NSMutableDictionary dictionary];
        _protocolIdentifiers = [NSMutableArray array];
    }
    return self;
}

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aCoder {
    if ((self = [super init]) != nil) {
        _binders = [aCoder decodeObjectForKey:@"binders"];
        _binderSetIdentifier = [aCoder decodeObjectForKey:@"binderSetIdentifier"];
        _protocolIdentifiers = [aCoder decodeObjectForKey:@"protocolIdentifiers"];
    }
    return self;
}

+ (instancetype _Nullable)unarchiveBinderSetAtURL:(NSURL * _Nonnull)url
                                            error:(NSError * __autoreleasing _Nullable * _Nullable)error {
    NSData * data;
    RNDBinderSet * binderSet;
    NSString * failureErrorMessage;
    
    data = [NSData dataWithContentsOfURL:url options:0 error:error];
    if (data == nil) { return nil; }
    @try {
        binderSet = (RNDBinderSet *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        if (error != NULL) {
            NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
            failureErrorMessage = [NSString stringWithFormat:@"Unable to locate: %@", [url absoluteString]];
            *error = [NSError errorWithDomain:RNDKitErrorDomain
                                         code:RNDExceptionAsError
                                     userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBinderSetCreationErrorKey, nil, errorBundle, @"Binder Set Creation Failed", @"BinderSet Creation Failed"),
                                                NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDBinderSetArchiveNotFoundErrorKey, nil, errorBundle, @"Unable to locate archive for the the binder set", failureErrorMessage),
                                                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDBinderSetCreationFailureRecoverySuggestionErrorKey, nil, errorBundle, @"Confirm that the identifier of the binding object exists and corresponds to an existing archive in the binding object's namespace.", @"The binder set was not created.")
                                                }];
        }
    } @finally {
        return nil;
    }
    
    return binderSet;
}

+ (instancetype _Nullable)unarchiveBinderSetWithID:(NSString * _Nonnull)binderSetIdentifier
                                         namespace:(NSString * _Nullable)binderSetNamespace
                                             error:(NSError * __autoreleasing _Nullable * _Nullable)error {
    NSData * data;
    RNDBinderSet * binderSet;
    NSURL *url;
    NSArray *bundles;
    NSString *binderSetFileName;
    NSString * failureErrorMessage;
    
    binderSetFileName = binderSetNamespace == nil ? binderSetIdentifier : [binderSetNamespace stringByAppendingFormat:@"-%@", binderSetIdentifier];
    bundles = [NSBundle allBundles];
    for (NSBundle *bundle in bundles) {
        url = [bundle URLForResource:binderSetFileName withExtension:@"rndbinderset"];
        if (url != nil) { break; }
    }
    if (url == nil) {
        if (error != NULL) {
            NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
            failureErrorMessage = [NSString stringWithFormat:@"Unable to locate: %@", binderSetFileName];
            *error = [NSError errorWithDomain:RNDKitErrorDomain
                                         code:RNDResourceNotFound
                                     userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBinderSetCreationErrorKey, nil, errorBundle, @"Binder Set Creation Failed", @"BinderSet Creation Failed"),
                                                NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDBinderSetArchiveNotFoundErrorKey, nil, errorBundle, @"Unable to locate archive for the the binder set", failureErrorMessage),
                                                         NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDBinderSetCreationFailureRecoverySuggestionErrorKey, nil, errorBundle, @"Confirm that the identifier of the binding object exists and corresponds to an existing archive in the binding object's namespace.", @"The binder set was not created.")
                                                         }];
        }
        return nil;
    }
    data = [NSData dataWithContentsOfURL:url
                                 options:0
                                   error:error];
    if (data == nil || error != NULL || error != nil) { return nil; }
    @try {
        binderSet = (RNDBinderSet *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        if (error != NULL) {
            NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
            failureErrorMessage = [NSString stringWithFormat:@"Unable to locate: %@", binderSetFileName];
            *error = [NSError errorWithDomain:RNDKitErrorDomain
                                         code:RNDExceptionAsError
                                     userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBinderSetCreationErrorKey, nil, errorBundle, @"Binder Set Creation Failed", @"BinderSet Creation Failed"),
                                                NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDBinderSetArchiveNotFoundErrorKey, nil, errorBundle, @"Unable to locate archive for the the binder set", failureErrorMessage),
                                                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDBinderSetCreationFailureRecoverySuggestionErrorKey, nil, errorBundle, @"Confirm that the identifier of the binding object exists and corresponds to an existing archive in the binding object's namespace.", @"The binder set was not created.")
                                                }];
        }
    } @finally {
        return nil;
    }

    return binderSet;

}

- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder {
    [aCoder encodeObject:_binders forKey:@"binders"];
    [aCoder encodeObject:_binderSetIdentifier forKey:@"binderSetIdentifier"];
    [aCoder encodeObject:_protocolIdentifiers forKey:@"protocolIdentifiers"];
}

- (BOOL)archiveBinderSetToURL:(NSURL * _Nonnull)directory
                        error:(NSError * __autoreleasing _Nullable * _Nullable)error {
    NSString * failureErrorMessage;

    if (_binderSetIdentifier == nil) {
        if (error != NULL) {
            NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
            failureErrorMessage = [NSString stringWithFormat:@"Unable to create archive."];
            *error = [NSError errorWithDomain:RNDKitErrorDomain
                                         code:RNDResourceCreationError
                                     userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBinderSetArchiveCreationErrorKey, nil, errorBundle, @"Binder Set Archive Creation Failed", @"Binder Set Archive Creation Failed"),
                                                NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDBinderSetArchiveDataIsNilErrorKey, nil, errorBundle, @"Unable to create archive for the the binder set. The binder set has no identifier.", failureErrorMessage),
                                                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDBinderSetArchiveCreationFailureRecoverySuggestionErrorKey, nil, errorBundle, @"Binder Sets must have an identifier to be archived. Add an identifier to the archive, or if using the RND Workbend, associate the Binder Set with a Nib-loadable object.", @"Nil binder set identifier.")
                                                }];
        }
        return NO;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if (data == nil) {
        if (error != NULL) {
            NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
            failureErrorMessage = [NSString stringWithFormat:@"Unable to create: %@", _binderSetIdentifier];
            *error = [NSError errorWithDomain:RNDKitErrorDomain
                                         code:RNDResourceCreationError
                                     userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBinderSetArchiveCreationErrorKey, nil, errorBundle, @"Binder Set Archive Creation Failed", @"Binder Set Archive Creation Failed"),
                                                NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDBinderSetArchiveDataIsNilErrorKey, nil, errorBundle, @"Unable to create archive for the the binder set", failureErrorMessage),
                                                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDBinderSetArchiveCreationFailureRecoverySuggestionErrorKey, nil, errorBundle, @"An unknown error during archiving has occurred that resulted in no archive data being produced.", @"Nil data for archive.")
                                                }];
        }
        return NO;
    }
    
    NSString *binderSetFileName = _binderSetNamespace == nil ? _binderSetIdentifier : [_binderSetNamespace stringByAppendingFormat:@"-%@.rndbinderset", _binderSetIdentifier];
    NSURL *fileURL = [directory URLByAppendingPathComponent:binderSetFileName];

    return [data writeToURL:fileURL options:NSDataWritingAtomic error:error];
}

- (BOOL)archiveBinderSet:(NSError * __autoreleasing _Nullable * _Nullable)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *directoryURL = [manager URLForDirectory:NSApplicationSupportDirectory
                                          inDomain:NSUserDomainMask
                                 appropriateForURL:nil
                                            create:YES
                                             error:error];
    if (directoryURL == nil) {
        return NO;
    }
    directoryURL = [directoryURL URLByAppendingPathComponent:@"RNDWorkbench" isDirectory:YES];
    BOOL result = [manager createDirectoryAtURL:directoryURL
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:error];
    if (result == NO) {
        return NO;
    }
    
    return [self archiveBinderSetToURL:directoryURL
                                 error:error];
}

#pragma mark - Dynamic Bindings
@synthesize protocolIdentifiers = _protocolIdentifiers;

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    for (NSString *protocolName in _protocolIdentifiers) {
        NSMethodSignature *signature = nil;
        Protocol *protocol = NSProtocolFromString(protocolName);
        if (protocol == nil) { break; } // TODO: This should be an error
        struct objc_method_description description = protocol_getMethodDescription(protocol, aSelector, YES, YES);
        if (description.name == NULL) { description = protocol_getMethodDescription(protocol, aSelector, NO, YES); }
        if (description.name == NULL) { break; }
        signature = [NSMethodSignature signatureWithObjCTypes:description.types];
        return signature;
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL targetSelector = [anInvocation selector];
    NSString *selectorString = NSStringFromSelector(targetSelector);
    RNDBinder *targetBinder = self.bindings.binders[selectorString];
    
    if (targetBinder == nil) { [super forwardInvocation:anInvocation]; }
    
    // If a result is required, set the invocation result. Otherwise just call the
    // binder's binding object value.
    if (strcmp("v", anInvocation.methodSignature.methodReturnType) == 0 ) {
        [targetBinder bindingObjectValueNeedsUpdate];
    } else {
        [self setReturnValue:[targetBinder updateBindingObjectValue] forInvocation:anInvocation];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSString *selectorString = NSStringFromSelector(aSelector);
    RNDBinder *targetBinder = self.bindings.binders[selectorString];

    if (targetBinder != nil) { return YES; }
    
    return [super respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    RNDBinder *targetBinder = self.bindings.binders[NSStringFromProtocol(aProtocol)];
    
    if (targetBinder != nil) { return YES; }
    
    return [super conformsToProtocol:aProtocol];
    
}

// TODO: Determine how to get size of array
- (void)setReturnValue:(id)value forInvocation:(NSInvocation *)invocation {
    [invocation retainArguments];
    const char *argumentType = invocation.methodSignature.methodReturnType;
    if (strcmp(argumentType, "c") == 0) {
        // value must be an NSNumber
        char buffer = [((NSNumber *)value) charValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "i") == 0) {
        // value must be an NSNumber
        int buffer = [((NSNumber *)value) intValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "s") == 0) {
        // value must be an NSNumber
        short buffer = [((NSNumber *)value) shortValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "l") == 0) {
        // value must be an NSNumber
        long buffer = [((NSNumber *)value) longValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "q") == 0) {
        // value must be an NSNumber
        long long buffer = [((NSNumber *)value) longLongValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "C") == 0) {
        // value must be an NSNumber
        unsigned char buffer = [((NSNumber *)value) unsignedCharValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "I") == 0) {
        // value must be an NSNumber
        unsigned int buffer = [((NSNumber *)value) unsignedIntValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "S") == 0) {
        // value must be an NSNumber
        unsigned short buffer = [((NSNumber *)value) unsignedShortValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "L") == 0) {
        // value must be an NSNumber
        unsigned long buffer = [((NSNumber *)value) unsignedLongLongValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "Q") == 0) {
        // value must be an NSNumber
        unsigned long long buffer = [((NSNumber *)value) unsignedLongLongValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "f") == 0) {
        // value must be an NSNumber
        float buffer = [((NSNumber *)value) floatValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "d") == 0) {
        // value must be an NSNumber
        double buffer = [((NSNumber *)value) doubleValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "B") == 0) {
        // value must be an NSNumber
        BOOL buffer = [((NSNumber *)value) boolValue];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "*") == 0) {
        const char *buffer = [(NSString *)value cStringUsingEncoding:[NSString defaultCStringEncoding]];
        [invocation setReturnValue:&buffer];
        return;
    } else if (strcmp(argumentType, "@") == 0) {
        [invocation setReturnValue:&value];
        return;
    } else if (strcmp(argumentType, "#") == 0) {
        [invocation setReturnValue:&value];
        return;
    } else if (strcmp(argumentType, ":") == 0) {
        SEL buffer = [((NSValue *)value) pointerValue];
        [invocation setReturnValue:&buffer];
        return;
        //    } else if (strncmp(argumentType, "[", 1) == 0) {
        //        NSUInteger length = invocation.methodSignature.methodReturnLength;
        //        void *buffer = (void *)malloc(length);
        //        [invocation getReturnValue:buffer];
        //        return [NSValue valueWithPointer:buffer];
    } else if (strncmp(argumentType, "{", 1) == 0) {
        // This is a structure argument that must be
        // of one of the supported types.
        if (strncmp(argumentType, "{NSRange", 8)) {
            NSRange buffer = (NSRange)[value rangeValue];
            [invocation setReturnValue:&buffer];
            return;
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
            CGPoint buffer = (CGPoint)[value CGPointValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{CGVector", 9)) {
            CGVector buffer = (CGVector)[value CGVectorValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{CGSize", 7)) {
            CGSize buffer = (CGSize)[value CGSizeValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{CGRect", 7)) {
            CGRect buffer = (CGRect)[value CGRectValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{CGAffineTransform", 18)) {
            CGAffineTransform buffer = (CGAffineTransform)[value CGAffineTransformValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{UIEdgeInsets", 13)) {
            UIEdgeInsets buffer = (UIEdgeInsets)[value UIEdgeInsetsValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{UIOffset", 9)) {
            UIOffset buffer = (UIOffset)[value UIOffsetValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{CATransform3D", 14)) {
            CATransform3D buffer = (CATransform3D)[value CATransform3DValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{CMTime", 7)) {
            CMTime buffer = (CMTime)[value CMTimeValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{CMTimeRange", 12)) {
            CMTimeRange buffer = (CMTimeRange)[value CMTimeRangeValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{CMTimeMapping", 14)) {
            CMTimeMapping buffer = (CMTimeMapping)[value CMTimeMappingValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{CLLocationCoordinate2D", 13)) {
            CLLocationCoordinate2D buffer = (CLLocationCoordinate2D)[value MKCoordinateValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{MKCoordinateSpan", 17)) {
            MKCoordinateSpan buffer = (MKCoordinateSpan)[value MKCoordinateSpanValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{SCNVector3", 11)) {
            SCNVector3 buffer = (SCNVector3)[value SCNVector3Value];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{SCNVector4", 11)) {
            SCNVector4 buffer = (SCNVector4)[value SCNVector4Value];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{SCNMatrix4", 11)) {
            SCNMatrix4 buffer = (SCNMatrix4)[value SCNMatrix4Value];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{NSDirectionalEdgeInsets", 24)) {
            NSDirectionalEdgeInsets buffer = (NSDirectionalEdgeInsets)[value directionalEdgeInsetsValue];
            [invocation setReturnValue:&buffer];
            return;
        } else if (strncmp(argumentType, "{NSEdgeInsets", 13)) {
            //            NSEdgeInsets bindingValue = argumentValue.NSEdgeInsetsValue;
            //            [invocation setArgument:&bindingValue atIndex:position];
        }
        //    } else if (strncmp(argumentType, "(", 1) == 0) {
        //        //
        //    } else if (strncmp(argumentType, "b", 1) == 0) {
        //        //
        //    } else if (strncmp(argumentType, "^", 1) == 0) {
        //        NSUInteger length = invocation.methodSignature.methodReturnLength;
        //        void *buffer = (void *)malloc(length);
        //        [invocation getReturnValue:buffer];
        //        return [NSValue valueWithPointer:buffer];
        //    } else if (strcmp(argumentType, "?") == 0) {
        //        //
        //    }
        
    }
}

@end
