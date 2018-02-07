//
//  RNDBinderSet.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/27/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//


#import "RNDBindingController.h"
#import "RNDBindings.h"
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVKit/AVKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "../RNDBindingMacros.h"

@interface RNDBindingController()

@end


@implementation RNDBindingController

@synthesize binderSetIdentifier = _binderSetIdentifier;

@synthesize binders = _binders;

- (NSError * _Nullable)setBinder:(RNDBinder * _Nonnull)binder forKey:(NSString * _Nonnull)key withBehavior:(NSString * _Nullable)behavior {
    
    return nil;
}

@synthesize coordinator = _coordinator;

@synthesize bound = _isBound;

@synthesize syncCoordinator = _syncCoordinator;

@synthesize coordinatorQueueIdentifier = _coordinatorQueueIdentifier;

@synthesize binderSetNamespace = _binderSetNamespace;

#pragma mark - Object Lifecycle
- (instancetype _Nullable)init {
    if ((self = [super init]) != nil) {
        _binders = [NSMutableDictionary dictionary];
        _protocolIdentifiers = [NSMutableArray array];
        _coordinatorQueueIdentifier = [[NSUUID alloc] init];
        _coordinator = dispatch_queue_create([[_coordinatorQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        _syncCoordinator = dispatch_semaphore_create(1);

    }
    return self;
}

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aCoder {
    if ((self = [super init]) != nil) {
        _binders = [aCoder decodeObjectForKey:@"binders"];
        _binderSetIdentifier = [aCoder decodeObjectForKey:@"binderSetIdentifier"];
        _protocolIdentifiers = [aCoder decodeObjectForKey:@"protocolIdentifiers"];
        _coordinatorQueueIdentifier = [[NSUUID alloc] init];
        _coordinator = dispatch_queue_create([[_coordinatorQueueIdentifier UUIDString] cStringUsingEncoding:[NSString defaultCStringEncoding]], DISPATCH_QUEUE_CONCURRENT);
        _syncCoordinator = dispatch_semaphore_create(1);

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

#pragma mark - Value Binder Support

RNDCoordinatedProperty(RNDBinder *, editorValue)

//@synthesize editorValue = _editorValue;
//
//- (RNDBinder *)editorValue {
//    id __block localObject;
//    dispatch_sync(self.coordinator, ^{
//        localObject = _editorValue;
//    });
//    return localObject;
//}
//
//- (void)setEditorValue:(RNDBinder *)editorValue {
//    dispatch_barrier_sync(self.coordinator, ^{
//        if (self.isBound == YES) { return; }
//        _editorValue = editorValue;
//    });
//}

RNDCoordinatedProperty(BOOL, registersAsEditor)

//@synthesize registersAsEditor = _registersAsEditor;
//
//- (BOOL)registersAsEditor {
//    BOOL __block localObject;
//    dispatch_sync(self.coordinator, ^{
//        localObject = _registersAsEditor;
//    });
//    return localObject;
//}
//
//- (void)setRegistersAsEditor:(BOOL)registersAsEditor {
//    dispatch_barrier_sync(self.coordinator, ^{
//        if (self.isBound == YES) { return; }
//        _registersAsEditor = registersAsEditor;
//    });
//}

#pragma mark - Editor Registration Support

@synthesize shouldBeginEditingEditorValue = _shouldBeginEditingEditorValue;

- (RNDBinder *)shouldBeginEditingEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _shouldBeginEditingEditorValue;
    });
    return localObject;
}

- (void)setShouldBeginEditingEditorValue:(RNDBinder *)shouldBeginEditingEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _shouldBeginEditingEditorValue = shouldBeginEditingEditorValue;
    });
}

@synthesize willBeginEditingEditorValue = _willBeginEditingEditorValue;

- (RNDBinder *)willBeginEditingEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _willBeginEditingEditorValue;
    });
    return localObject;
}

- (void)setWillBeginEditingEditorValue:(RNDBinder *)willBeginEditingEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _willBeginEditingEditorValue = willBeginEditingEditorValue;
    });
}

@synthesize didBeginEditingEditorValue = _didBeginEditingEditorValue;

- (RNDBinder *)didBeginEditingEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _didBeginEditingEditorValue;
    });
    return localObject;
}

- (void)setDidBeginEditingEditorValue:(RNDBinder *)didBeginEditingEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _didBeginEditingEditorValue = didBeginEditingEditorValue;
    });
}

@synthesize shouldEndEditingEditorValue = _shouldEndEditingEditorValue;

- (RNDBinder *)shouldEndEditingEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _shouldEndEditingEditorValue;
    });
    return localObject;
}

- (void)setShouldEndEditingEditorValue:(RNDBinder *)shouldEndEditingEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _shouldEndEditingEditorValue = shouldEndEditingEditorValue;
    });
}

@synthesize willEndEditingEditorValue = _willEndEditingEditorValue;

- (RNDBinder *)willEndEditingEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _willEndEditingEditorValue;
    });
    return localObject;
}

- (void)setWillEndEditingEditorValue:(RNDBinder *)willEndEditingEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _willEndEditingEditorValue = willEndEditingEditorValue;
    });
}

@synthesize didEndEditingEditorValue = _didEndEditingEditorValue;

- (RNDBinder *)didEndEditingEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _didEndEditingEditorValue;
    });
    return localObject;
}

- (void)setDidEndEditingEditorValue:(RNDBinder *)didEndEditingEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _didEndEditingEditorValue = didEndEditingEditorValue;
    });
}


// Triggers a call to associated Editor Registration binders
- (BOOL)editorShouldBeginEditingEditorValue:(id _Nullable)value {
    return _shouldBeginEditingEditorValue.bindingValue;
}
- (void)editorWillBeginEditingEditorValue:(id _Nullable)value {
    // Notifies the data controller that an edit is going to occur.
}
- (void)editorDidBeginEditingEditorValue:(id _Nullable)value {
    // Notifies the data controller that an edit is happening
}
- (BOOL)editorShouldEndEditingEditorValue:(id _Nullable)value {
    // Determines if an edit should occur
    return _shouldEndEditingEditorValue.bindingValue;
}
- (void)editorWillEndEditingEditorValue:(id _Nullable)value {
    // Notifies the data controller than an edit is goind to occur.
}
- (void)editorDidEndEditingEditorValue:(id _Nullable)value {
    // Notifies the data controller than an edit is happening.
}

#pragma mark - Value Update Support

@synthesize validatesEditorValueUpdateImmediately = _validatesEditorValueUpdateImmediately;
// The controller will use it's shouldUpdateEditorValue binder to validate any update to the editor value made during and editor session.
- (BOOL)validatesEditorValueUpdateImmediately {
    BOOL __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _validatesEditorValueUpdateImmediately;
    });
    return localObject;
};

- (void)setValidatesEditorValueUpdateImmediately:(BOOL)validatesEditorValueUpdateImmediately {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _validatesEditorValueUpdateImmediately = validatesEditorValueUpdateImmediately;
    });
}

@synthesize editorValueIsValid = _editorValueIsValid;

- (BOOL)editorValueIsValid {
    BOOL __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _editorValueIsValid;
    });
    return localObject;
}

- (void)setEditorValueIsValid:(BOOL)editorValueIsValid {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _editorValueIsValid = editorValueIsValid;
    });
}

@synthesize editorValueValidationError = _editorValueValidationError;

- (NSError *)editorValueValidationError {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _editorValueValidationError;
    });
    return localObject;
}

- (void)setEditorValueValidationError:(NSError *)editorValueValidationError {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _editorValueValidationError = editorValueValidationError;
    });
}

@synthesize shouldUpdateEditorValue = _shouldUpdateEditorValue;

- (RNDBinder *)shouldUpdateEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _shouldUpdateEditorValue;
    });
    return localObject;
}

- (void)setShouldUpdateEditorValue:(RNDBinder *)shouldUpdateEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _shouldUpdateEditorValue = shouldUpdateEditorValue;
    });
}

- (BOOL)editorShouldUpdateEditorValue:(id _Nullable)value {
    return _shouldUpdateEditorValue.bindingValue;
}


@synthesize willUpdateEditorValue = _willUpdateEditorValue;

- (RNDBinder *)willUpdateEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _willUpdateEditorValue;
    });
    return localObject;
}

- (void)setWillUpdateEditorValue:(RNDBinder *)willUpdateEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _willUpdateEditorValue = willUpdateEditorValue;
    });
}

- (void)editorWillUpdateEditorValue:(id _Nullable)value {
    
}

@synthesize didUpdateEditorValue = _didUpdateEditorValue;

- (RNDBinder *)didUpdateEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _didUpdateEditorValue;
    });
    return localObject;
}

- (void)setDidUpdateEditorValue:(RNDBinder *)didUpdateEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _didUpdateEditorValue = didUpdateEditorValue;
    });
}

- (void)editorDidUpdatedEditorValue:(id _Nullable)value {
    
}

#pragma mark - Value Replacement Support

@synthesize shouldReplaceEditorValue = _shouldReplaceEditorValue;

- (RNDBinder *)shouldReplaceEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _shouldReplaceEditorValue;
    });
    return localObject;
}; // When underlying data changes during an edit session. The binder calls set value for keypath on the controller (as the editor proxy).

- (void)setShouldReplaceEditorValue:(RNDBinder *)shouldReplaceEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _shouldReplaceEditorValue = shouldReplaceEditorValue;
    });
}

@synthesize willReplaceEditorValue = _willReplaceEditorValue;

- (RNDBinder *)willReplaceEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _willReplaceEditorValue;
    });
    return localObject;
} // When underlying data changes during an edit session. The binder calls set value for keypath on the controller (as the editor proxy).

- (void)setWillReplaceEditorValue:(RNDBinder *)willReplaceEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _willReplaceEditorValue = willReplaceEditorValue;
    });
}

@synthesize didReplaceEditorValue = _didReplaceEditorValue;

- (RNDBinder *)didReplaceEditorValue {
    id __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _didReplaceEditorValue;
    });
    return localObject;
} // When underlying data changes during an edit session. The binder calls set value for keypath on the controller (as the editor proxy).

- (void)setDidReplaceEditorValue:(RNDBinder *)didReplaceEditorValue {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _didReplaceEditorValue = didReplaceEditorValue;
    });
}

@synthesize editorValueLockingFailure = _editorValueLockingFailure;

- (BOOL)editorValueLockingFailure {
    BOOL __block localObject;
    dispatch_sync(self.coordinator, ^{
        localObject = _editorValueLockingFailure;
    });
    return localObject;
} // Observable - An optimistic locking failure occurs when the should replace editor value returns no, preventing the editor from basing its edit on the datasource value.
- (void)setEditorValueLockingFailure:(BOOL)editorValueLockingFailure {
    dispatch_barrier_sync(self.coordinator, ^{
        if (self.isBound == YES) { return; }
        _editorValueLockingFailure = editorValueLockingFailure;
    });
}

- (BOOL)editorValue:(id _Nullable)editorValue shouldChangeToNewValue:(id _Nullable)newValue fromPriorValue:(id _Nullable)dataSourceValue {
    
}; // If an optimistic locking failure has occurred where the current model value does not match the edited value, provides the binder with an opportunity to confirm that the change should occur.

// These are the methods that binders call on their binding controllers when specific key paths change. Set value for keypath is used to make the actual change as part of the updateBindingObjectValue method in a binder.
- (void)dataSourceWillReplaceBoundValue:(id _Nullable)value forKeyPath:(NSString * _Nonnull)keyPath {
    
}; // Tells the controller that the value in the model will change while an edit in is progress.
- (void)dataSourceDidReplaceBoundValue:(id _Nullable)value forKeyPath:(NSString * _Nonnull)keyPath {
    
}; // Tells the controller that the value in the model will change while an edit is in progress.

- (void)discardEditorValue {
    
}; // Reverts to the current binding value and pushes it to the Editor(view).

- (BOOL)commitEditorValue {
    
}; // Generally called by a mediating controller that has the binder registered as an editor.

- (void)commitEditorValueWithDelegate:(nullable id<RNDEditorDelegate>)delegate contextInfo:(nullable void *)contextInfo {
    
}; // Generally called by an external actor that waits for an async result. For example, a save button that triggers a write to a remote database.

- (BOOL)commitEditorValueAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error {
    
}; // Generally called by the object(editor) associated with the binder. Provide a way to automatically present an eror message.

#pragma mark - Binding Management

- (BOOL)bindCoordinatedObjects:(NSError *__autoreleasing  _Nullable *)error {
    BOOL result = YES;
    NSError *internalError = nil;
    
    dispatch_assert_queue_debug(_coordinator);
    
    if (_isBound == YES) {
        result = NO;
        if (error != NULL) {
            NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
            internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                code:RNDObjectIsBoundError
                                            userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundErrorKey, nil, errorBundle, @"The binder is already bound.", @"The binder is already bound."),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundRecoverySuggestionErrorKey, nil, errorBundle, @"The binder is already bound. To rebind the binder, call unbind on the binder first.", @"Attempted to rebind the binder.")
                                                       }];
            *error = internalError;
        }
        return result;
    }
    
    if (_monitorsBindingObject == YES) {
        if (_bindingObject == nil) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDObservedObjectIsNil
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDObserverObjectIsNilErrorKey, nil, errorBundle, @"The observer object is nil.", @"The observer object is nil."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectRecoverySuggestionErrorKey, nil, errorBundle, @"If loading from an archive, confirm that the binder set containing the binder has a valid observed object. Alternatively, confirm that the  binder set containing the binder references the correct binding Identifier in the Xib or Storyboard in the RNDWorkbench application and then regenerate the archive.\n\nIf not loading from an archive, confirm that the observer object is set prior to attempting to bind the binder.", @"The observer object is nil and can not be KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;
        } else if ([_bindingObject isKindOfClass:[RNDBindingProcessor class]] == YES) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDAttemptToObserveProcessorError
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectErrorKey, nil, errorBundle, @"The observer object is a processor.", @"The observer object is a processor."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObserverObjectRecoverySuggestionErrorKey, nil, errorBundle, @"The binder has been set to monitor another processor. Processors can not be monitored. Change the monitors observer setting of this binder to false to correct this error./n/n If you are using the RNDWorkbench, uncheck the monitors observer checkbox for this binder.", @"The observer object is a processor and can not be KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;
            
        } else if (_bindingObjectKeyPath == nil) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDKeyValuePathError
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDKeyPathIsNilErrorKey, nil, errorBundle, @"The observer object keypath is nil.", @"The observer object keypath is nil."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectRecoverySuggestionErrorKey, nil, errorBundle, @"A keypath corresponding to an observable relationship of an object must be specified to enable monitoring./n/nIf you are using the RNDWorkbench, either uncheck the monitors observer checkbox for this binder or specify an observable property keypath to monitor.", @"The keypath of the observer object is nil and will prevent the observer object from being KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;
        } else if (_bindingName == nil) {
            result = NO;
            if (error != NULL) {
                NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
                internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                    code:RNDKeyValuePathError
                                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                           NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDBindingNameIsNilErrorKey, nil, errorBundle, @"The binder binding name is nil.", @"The binder binding name is nil."),
                                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDMonitorObservedObjectRecoverySuggestionErrorKey, nil, errorBundle, @"A binding name must be provided when monitoring the observer./n/nIf you are using the RNDWorkbench, add a binding name or check or check the Use Default Name checkbox in the Binder Properties.", @"The binder's binding name is nil and will prevent the observer object from being KVO'd.")
                                                           }];
                *error = internalError;
            }
            return result;
        }
        
        [_bindingObject addObserver:self
                         forKeyPath:_bindingObjectKeyPath
                            options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionPrior |  NSKeyValueObservingOptionOld)
                            context:(__bridge void * _Nullable)(_bindingName)];
    }
    
    // The processors must receive a bind message.
    _inflowProcessor.binder = self;
    if (_inflowProcessor != nil && [_inflowProcessor bind:error] == NO) {
        [self unbindCoordinatedObjects:error];
        return NO;
    }
    
    _boundOutflowProcessors = [NSArray arrayWithArray:_outflowProcessors];
    for (RNDBindingProcessor *processor in _boundOutflowProcessors) {
        processor.binder = self;
        if ([processor bind:error] == NO) {
            [self unbindCoordinatedObjects:error];
            return NO;
        }
    }
    
    _isBound = YES;
    return _isBound;
}

- (void)bind {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    dispatch_sync(_coordinator, ^{
        [self bindCoordinatedObjects:nil];
    });
    dispatch_semaphore_signal(_syncCoordinator);
}

- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    __block BOOL result = NO;
    dispatch_sync(_coordinator, ^{
        result = [self bindCoordinatedObjects:error];
    });
    dispatch_semaphore_signal(_syncCoordinator);
    return result;
}

- (BOOL)unbindCoordinatedObjects:(NSError * _Nullable __autoreleasing * _Nullable)error {
    BOOL result = YES;
    id underlyingError;
    NSMutableArray *underlyingErrorsArray = [NSMutableArray array];
    NSError * internalError;
    
    dispatch_assert_queue_debug(self.coordinator);
    
    @try {
        if (_isBound == YES && _monitorsBindingObject == YES) {
            [_bindingObject removeObserver:self
                                forKeyPath:_bindingObjectKeyPath
                                   context:(__bridge void * _Nullable)(_bindingName)];
        }
    }
    
    @catch (id exception) {
        result = NO;
        if (error != NULL) {
            if ([exception isKindOfClass:[NSException class]] == YES) {
                NSException * exceptionObj = (NSException *)exception;
                NSMutableDictionary *exceptionDictionary = [NSMutableDictionary dictionaryWithDictionary:exceptionObj.userInfo != nil ? exceptionObj.userInfo : @{}];
                [exceptionDictionary addEntriesFromDictionary:@{NSLocalizedDescriptionKey: exceptionObj.name, NSLocalizedFailureReasonErrorKey: exceptionObj.reason != nil ? exceptionObj.reason : [NSNull null]}];
                underlyingError = [NSError errorWithDomain:RNDKitErrorDomain
                                                      code:RNDExceptionAsError
                                                  userInfo:[NSDictionary dictionaryWithDictionary:exceptionDictionary]];
            } else {
                underlyingError = exception;
            }
        }
    }
    
    NSError *passedInError;
    BOOL unbindingResult = [_inflowProcessor unbind:&passedInError];
    if (unbindingResult == NO) {
        result = NO;
        if (passedInError != nil) { [underlyingErrorsArray addObject:passedInError]; }
    }
    
    for (RNDBindingProcessor *processor in _boundOutflowProcessors) {
        unbindingResult = [processor unbind:&passedInError];
        if (unbindingResult == NO) {
            result = NO;
            if (passedInError != nil) { [underlyingErrorsArray addObject:passedInError]; }
        }
    }
    _boundOutflowProcessors = nil;
    
    if (error != NULL && (underlyingErrorsArray.count > 0 || underlyingError != nil)) {
        NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
        internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                            code:RNDProcessorIsNotRegisteredAsObserver
                                        userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDUnbindingErrorKey, nil, errorBundle, @"Unbinding Error", @"Unbinding Error"),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDUnbindingUnregistrationErrorKey, nil, errorBundle, @"An error occurred during unbinding.", @"An error occurred during unbinding."),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDUnbindingExceptionRecoverySuggestionErrorKey, nil, errorBundle, @"An exception was thrown during unbinding. The most likely cause is that the processor was not registered as an observer of the observed object. See the underlying error for more information and to trace the cause of the exception.", @"The processor was not registered as an observer."),
                                                   NSUnderlyingErrorKey:underlyingError,
                                                   RNDUnderlyingErrorsArrayKey: underlyingErrorsArray
                                                   }];
        *error = internalError;
    }
    
    _isBound = NO;
    return result;
}

- (void)unbind {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    dispatch_sync(_coordinator, ^{
        [self unbindCoordinatedObjects:nil];
    });
    dispatch_semaphore_signal(_syncCoordinator);
}

- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    __block BOOL result = NO;
    dispatch_sync(_coordinator, ^{
        result = [self unbindCoordinatedObjects:error];
    });
    dispatch_semaphore_signal(_syncCoordinator);
    return result;
}

@end
