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

@property (readwrite) BOOL bound;
@property(nonnull, readonly) RNDCoordinatedDictionary<NSString *, NSString *> *behaviorToSelectorString;
@property(nonnull, readonly) RNDCoordinatedDictionary<NSString *, NSString *> *selectorStringToBehavior;

@end


@implementation RNDBindingController

@synthesize binderSetIdentifier = _binderSetIdentifier;

@synthesize binders = _binders;

- (NSError * _Nullable)setBinder:(RNDBinder * _Nonnull)binder forBehavior:(NSString * _Nonnull)behavior withSelectorString:(NSString * _Nullable)selectorString {
    
    return nil;
}

@synthesize coordinatorLock = _coordinatorLock;

@synthesize syncCoordinator = _syncCoordinator;

@synthesize binderSetNamespace = _binderSetNamespace;

RNDCoordinatedProperty(BOOL, bound, Bound);

#pragma mark - Object Lifecycle
- (instancetype _Nullable)init {
    if ((self = [super init]) != nil) {
        _binders = [RNDCoordinatedDictionary dictionary];
        _protocolIdentifiers = [RNDCoordinatedArray array];
        _syncCoordinator = dispatch_semaphore_create(1);
        _coordinatorLock = [NSRecursiveLock new];
    }
    return self;
}

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aCoder {
    if ((self = [super init]) != nil) {
        _binders = [aCoder decodeObjectForKey:@"binders"];
        _binderSetIdentifier = [aCoder decodeObjectForKey:@"binderSetIdentifier"];
        _protocolIdentifiers = [aCoder decodeObjectForKey:@"protocolIdentifiers"];
        _syncCoordinator = dispatch_semaphore_create(1);
        _coordinatorLock = [NSRecursiveLock new];
    }
    return self;
}

+ (instancetype _Nullable)unarchiveBinderSetAtURL:(NSURL * _Nonnull)url
                                            error:(NSError * __autoreleasing _Nullable * _Nullable)error {
    NSData * data;
    RNDBindingController * controller;
    NSString * failureErrorMessage;
    
    data = [NSData dataWithContentsOfURL:url options:0 error:error];
    if (data == nil) { return nil; }
    @try {
        controller = (RNDBindingController *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
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
    
    return controller;
}

+ (instancetype _Nullable)unarchiveBinderSetWithID:(NSString * _Nonnull)binderSetIdentifier
                                         namespace:(NSString * _Nullable)binderSetNamespace
                                             error:(NSError * __autoreleasing _Nullable * _Nullable)error {
    NSData * data;
    RNDBindingController * controller;
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
        controller = (RNDBindingController *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
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

    return controller;

}

- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder {
    [_coordinatorLock lock];
    [aCoder encodeObject:_binders forKey:@"binders"];
    [aCoder encodeObject:_binderSetIdentifier forKey:@"binderSetIdentifier"];
    [aCoder encodeObject:_protocolIdentifiers forKey:@"protocolIdentifiers"];
    [_coordinatorLock unlock];
}

- (BOOL)archiveBinderSetToURL:(NSURL * _Nonnull)directory
                        error:(NSError * __autoreleasing _Nullable * _Nullable)error {

    [_coordinatorLock lock];

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
        [_coordinatorLock unlock];
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
        [_coordinatorLock unlock];
        return NO;
    }
    
    NSString *binderSetFileName = _binderSetNamespace == nil ? _binderSetIdentifier : [_binderSetNamespace stringByAppendingFormat:@"-%@.rndbinderset", _binderSetIdentifier];
    NSURL *fileURL = [directory URLByAppendingPathComponent:binderSetFileName];
    
    [_coordinatorLock unlock];
    return [data writeToURL:fileURL options:NSDataWritingAtomic error:error];
}

- (BOOL)archiveBinderSet:(NSError * __autoreleasing _Nullable * _Nullable)error {
    [_coordinatorLock lock];

    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *directoryURL = [manager URLForDirectory:NSApplicationSupportDirectory
                                          inDomain:NSUserDomainMask
                                 appropriateForURL:nil
                                            create:YES
                                             error:error];
    if (directoryURL == nil) {
        [_coordinatorLock unlock];
        return NO;
    }
    directoryURL = [directoryURL URLByAppendingPathComponent:@"RNDWorkbench" isDirectory:YES];
    BOOL result = [manager createDirectoryAtURL:directoryURL
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:error];
    if (result == NO) {
        [_coordinatorLock unlock];
        return NO;
    }
    
    [_coordinatorLock unlock];
    return [self archiveBinderSetToURL:directoryURL
                                 error:error];
}

#pragma mark - Dynamic Bindings
@synthesize protocolIdentifiers = _protocolIdentifiers;

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    [_coordinatorLock lock];
    
    for (NSString *protocolName in _protocolIdentifiers) {
        NSMethodSignature *signature = nil;
        Protocol *protocol = NSProtocolFromString(protocolName);
        if (protocol == nil) { break; } // TODO: This should be an error
        struct objc_method_description description = protocol_getMethodDescription(protocol, aSelector, YES, YES);
        if (description.name == NULL) { description = protocol_getMethodDescription(protocol, aSelector, NO, YES); }
        if (description.name == NULL) { break; }
        signature = [NSMethodSignature signatureWithObjCTypes:description.types];

        [_coordinatorLock unlock];
        return signature;
    }
    
    [_coordinatorLock unlock];
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [_coordinatorLock lock];
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
    [_coordinatorLock unlock];

}

- (BOOL)respondsToSelector:(SEL)aSelector {
    
    [_coordinatorLock lock];
    
    NSString *selectorString = NSStringFromSelector(aSelector);
    RNDBinder *targetBinder = self.bindings.binders[selectorString];

    if (targetBinder != nil) { return YES; }
    
    [_coordinatorLock unlock];
    return [super respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    
    [_coordinatorLock lock];
    
    RNDBinder *targetBinder = self.bindings.binders[NSStringFromProtocol(aProtocol)];
    
    if (targetBinder != nil) {
        
        [_coordinatorLock unlock];
        return YES;
    }
    
    [_coordinatorLock unlock];
    return [super conformsToProtocol:aProtocol];
    
}

// TODO: Determine how to get size of array
- (void)setReturnValue:(id)value forInvocation:(NSInvocation *)invocation {
    [_coordinatorLock lock];
    
    [invocation retainArguments];
    const char *argumentType = invocation.methodSignature.methodReturnType;
    if (strcmp(argumentType, "c") == 0) {
        // value must be an NSNumber
        char buffer = [((NSNumber *)value) charValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "i") == 0) {
        // value must be an NSNumber
        int buffer = [((NSNumber *)value) intValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "s") == 0) {
        // value must be an NSNumber
        short buffer = [((NSNumber *)value) shortValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "l") == 0) {
        // value must be an NSNumber
        long buffer = [((NSNumber *)value) longValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "q") == 0) {
        // value must be an NSNumber
        long long buffer = [((NSNumber *)value) longLongValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "C") == 0) {
        // value must be an NSNumber
        unsigned char buffer = [((NSNumber *)value) unsignedCharValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "I") == 0) {
        // value must be an NSNumber
        unsigned int buffer = [((NSNumber *)value) unsignedIntValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "S") == 0) {
        // value must be an NSNumber
        unsigned short buffer = [((NSNumber *)value) unsignedShortValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "L") == 0) {
        // value must be an NSNumber
        unsigned long buffer = [((NSNumber *)value) unsignedLongLongValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "Q") == 0) {
        // value must be an NSNumber
        unsigned long long buffer = [((NSNumber *)value) unsignedLongLongValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "f") == 0) {
        // value must be an NSNumber
        float buffer = [((NSNumber *)value) floatValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "d") == 0) {
        // value must be an NSNumber
        double buffer = [((NSNumber *)value) doubleValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "B") == 0) {
        // value must be an NSNumber
        BOOL buffer = [((NSNumber *)value) boolValue];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "*") == 0) {
        const char *buffer = [(NSString *)value cStringUsingEncoding:[NSString defaultCStringEncoding]];
        [invocation setReturnValue:&buffer];

    } else if (strcmp(argumentType, "@") == 0) {
        [invocation setReturnValue:&value];

    } else if (strcmp(argumentType, "#") == 0) {
        [invocation setReturnValue:&value];

    } else if (strcmp(argumentType, ":") == 0) {
        SEL buffer = [((NSValue *)value) pointerValue];
        [invocation setReturnValue:&buffer];

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

        } else if (strncmp(argumentType, "{CGVector", 9)) {
            CGVector buffer = (CGVector)[value CGVectorValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{CGSize", 7)) {
            CGSize buffer = (CGSize)[value CGSizeValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{CGRect", 7)) {
            CGRect buffer = (CGRect)[value CGRectValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{CGAffineTransform", 18)) {
            CGAffineTransform buffer = (CGAffineTransform)[value CGAffineTransformValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{UIEdgeInsets", 13)) {
            UIEdgeInsets buffer = (UIEdgeInsets)[value UIEdgeInsetsValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{UIOffset", 9)) {
            UIOffset buffer = (UIOffset)[value UIOffsetValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{CATransform3D", 14)) {
            CATransform3D buffer = (CATransform3D)[value CATransform3DValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{CMTime", 7)) {
            CMTime buffer = (CMTime)[value CMTimeValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{CMTimeRange", 12)) {
            CMTimeRange buffer = (CMTimeRange)[value CMTimeRangeValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{CMTimeMapping", 14)) {
            CMTimeMapping buffer = (CMTimeMapping)[value CMTimeMappingValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{CLLocationCoordinate2D", 13)) {
            CLLocationCoordinate2D buffer = (CLLocationCoordinate2D)[value MKCoordinateValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{MKCoordinateSpan", 17)) {
            MKCoordinateSpan buffer = (MKCoordinateSpan)[value MKCoordinateSpanValue];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{SCNVector3", 11)) {
            SCNVector3 buffer = (SCNVector3)[value SCNVector3Value];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{SCNVector4", 11)) {
            SCNVector4 buffer = (SCNVector4)[value SCNVector4Value];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{SCNMatrix4", 11)) {
            SCNMatrix4 buffer = (SCNMatrix4)[value SCNMatrix4Value];
            [invocation setReturnValue:&buffer];

        } else if (strncmp(argumentType, "{NSDirectionalEdgeInsets", 24)) {
            NSDirectionalEdgeInsets buffer = (NSDirectionalEdgeInsets)[value directionalEdgeInsetsValue];
            [invocation setReturnValue:&buffer];

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
    
    [_coordinatorLock unlock];

}

#pragma mark - Value Binder Support

#pragma mark editorValue
RNDCoordinatedProperty(RNDBinder *, valueBinder, ValueBinder)

#pragma mark registersAsEditor
RNDCoordinatedProperty(BOOL, registersAsEditor, RegistersAsEditor)

#pragma mark - Editor Registration Support

#pragma mark shouldBeginEditingEditorValue
RNDCoordinatedProperty(RNDBinder *, shouldBeginEditBinder, ShouldBeginEditBinder)

#pragma mark willBeginEditingEditorValue
RNDCoordinatedProperty(RNDBinder *, willBeginEditBinder, WillBeginEditBinder)

#pragma mark didBeginEditingEditorValue
RNDCoordinatedProperty(RNDBinder *, didBeginEditBinder, DidBeginEditBinder)

#pragma mark shouldEndEditingEditorValue
RNDCoordinatedProperty(RNDBinder *, shouldEndEditBinder, ShouldEndEditBinder)

#pragma mark willEndEditingEditorValue
RNDCoordinatedProperty(RNDBinder *, willEndEditBinder, WillEndEditBinder)

#pragma mark didEndEditingEditorValue
RNDCoordinatedProperty(RNDBinder *, didEndEditBinder, DidEndEditBinder)

// Triggers a call to associated Editor Registration binders
- (BOOL)editorShouldBeginEditingEditorValue:(id _Nullable)value {
    return _shouldBeginEditBinder.bindingValue;
}
- (void)editorWillBeginEditingEditorValue:(id _Nullable)value {
    // Notifies the data controller that an edit is going to occur.
    // NO-OP
}
- (void)editorDidBeginEditingEditorValue:(id _Nullable)value {
    // Notifies the data controller that an edit is happening by calling the
    // editor value binder's register for edit
    [_valueBinder editorDidBeginEditing:self];
}
- (BOOL)editorShouldEndEditingEditorValue:(id _Nullable)value {
    // Determines if an edit should end
    return _shouldEndEditBinder.bindingValue;
}
- (void)editorWillEndEditingEditorValue:(id _Nullable)value {
    // Notifies the data controller than an edit is goind to end.
    // NO-OP
}
- (void)editorDidEndEditingEditorValue:(id _Nullable)value {
    // Notifies the data controller than an edit is complete and the editor should be unregistered.
    [_valueBinder editorDidEndEditing:self];
}

#pragma mark - Value Update Support

#pragma mark validatesEditorValueUpdateImmediately
RNDCoordinatedProperty(BOOL, validatesEditorValueUpdateImmediately, ValidatesEditorValueUpdateImmediately)

#pragma mark editorValueIsValid
RNDCoordinatedProperty(BOOL, editorValueIsValid, EditorValueIsValid)

#pragma mark editorValueValidationError
RNDCoordinatedProperty(NSError *, editorValueValidationError, EditorValueValidationError)

#pragma mark shouldUpdateEditorValue
RNDCoordinatedProperty(RNDBinder *, shouldUpdateEditorValue, ShouldUpdateEditorValue)

- (BOOL)editorShouldUpdateEditorValue:(id _Nullable)value {
    return _shouldUpdateEditorValue.bindingValue;
}

#pragma mark willUpdateEditorValue
RNDCoordinatedProperty(RNDBinder *, willUpdateEditorValue, WillUpdateEditorValue)

- (void)editorWillUpdateEditorValue:(id _Nullable)value {
    // NO-OP
}

#pragma mark didUpdateEditorValue
RNDCoordinatedProperty(RNDBinder *, didUpdateEditorValue, DidUpdateEditorValue)

- (void)editorDidUpdatedEditorValue:(id _Nullable)value {
    // NO-OP
}

#pragma mark - Value Replacement Support

#pragma mark shouldReplaceEditorValue
RNDCoordinatedProperty(RNDBinder *, shouldReplaceEditorValue, ShouldReplaceEditorValue)

#pragma mark willReplaceEditorValue
RNDCoordinatedProperty(RNDBinder *, willReplaceEditorValue, WillReplaceEditorValue)

#pragma mark didReplaceEditorValue
RNDCoordinatedProperty(RNDBinder *, didReplaceEditorValue, DidReplaceEditorValue)

#pragma mark editorValueLockingFailure

RNDCoordinatedProperty(BOOL, editorValueLockingFailure, EditorValueLockingFailure)

- (BOOL)editing {
    [_coordinatorLock lock];
    BOOL localObject = _editing;
    [_coordinatorLock unlock];
    return localObject;
}

- (BOOL)editorValue:(id _Nonnull)editorValue shouldChangeToNewValue:(id _Nonnull)newValue fromPriorValue:(id _Nonnull)dataSourceValue {
    // If an optimistic locking failure has occurred where the current model value does not match the edited value, provides the binder with an opportunity to confirm that the change should occur.
    BOOL result = YES;
    [_coordinatorLock lock];
    
    if (_editing == YES && _shouldReplaceEditorValue != nil) {
        // This method should only be called when an edit is in progress and the shouldReplaceEditorValue binder is not nil.
        id runtimeArgs = [NSMutableDictionary dictionaryWithDictionary:@{RNDPriorValue: dataSourceValue, RNDCurrentValue: editorValue, RNDNewValue:newValue}];
        if (_shouldReplaceEditorValue.inflowProcessor.runtimeArguments != nil) {
            [runtimeArgs addEntriesFromDictionary:_shouldReplaceEditorValue.inflowProcessor.runtimeArguments];
        }
        _shouldReplaceEditorValue.inflowProcessor.runtimeArguments = [NSDictionary dictionaryWithDictionary:runtimeArgs];
        result = ((NSNumber *)_shouldReplaceEditorValue.bindingValue).boolValue;
    }
    
    [_coordinatorLock unlock];
    return result;
};


- (void)dataSourceWillReplaceBoundValue:(id _Nullable)value atKeyPath:(NSString * _Nonnull)keyPath {
    self.editorValueLockingFailure = YES;
};
- (void)dataSourceDidReplaceBoundValue:(id _Nullable)value atKeyPath:(NSString * _Nonnull)keyPath {
    
};

- (void)discardEditorValue {
    // This should call dataSourceWillReplaceBoundValue, should change the value, and then call didreplace.
}; // Reverts to the current binding value and pushes it to the Editor(view).

- (BOOL)commitEditorValue {
    
    return NO;
}; // Generally called by a mediating controller that has the binder registered as an editor.

- (void)commitEditorValueWithDelegate:(nullable id<RNDEditorDelegate>)delegate contextInfo:(nullable void *)contextInfo {
    
}; // Generally called by an external actor that waits for an async result. For example, a save button that triggers a write to a remote database.

- (BOOL)commitEditorValueAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error {
    
    return NO;
}; // Generally called by the object(editor) associated with the binder. Provide a way to automatically present an eror message.

#pragma mark - Binding Management

- (BOOL)bindCoordinatedObjects:(NSError *__autoreleasing  _Nullable *)error {
    BOOL result = YES;
    NSError *internalError = nil;
    
    if (_bound == YES) {
        result = NO;
        if (error != NULL) {
            NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
            internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                code:RNDObjectIsBoundError
                                            userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Binding Failed", @"Binding Failed"),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundErrorKey, nil, errorBundle, @"The binding controller is already bound.", @"The binding controller is already bound."),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundRecoverySuggestionErrorKey, nil, errorBundle, @"The binding controller is already bound. To rebind the it, call unbind first.", @"Attempted to rebind the binding controller.")
                                                       }];
            *error = internalError;
        }
        return result;
    }
    
    result = [self.binders bind:&internalError];
    
    _bound = result;
    return result;
}

- (void)bind {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    [_coordinatorLock lock];
    [self bindCoordinatedObjects:nil];
    [_coordinatorLock unlock];
    dispatch_semaphore_signal(_syncCoordinator);
}

- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    [_coordinatorLock lock];
    __block BOOL result = [self bindCoordinatedObjects:error];
    [_coordinatorLock unlock];
    dispatch_semaphore_signal(_syncCoordinator);
    return result;
}

- (BOOL)unbindCoordinatedObjects:(NSError * _Nullable __autoreleasing * _Nullable)error {
    BOOL result = YES;
    id underlyingError;
    NSMutableArray *underlyingErrorsArray = [NSMutableArray array];
    NSError * internalError;
    
    if (_bound == NO) {
        result = NO;
        if (error != NULL) {
            NSBundle * errorBundle = [NSBundle bundleForClass:[self class]];
            internalError = [NSError errorWithDomain:RNDKitErrorDomain
                                                code:RNDObjectIsBoundError
                                            userInfo:@{NSLocalizedDescriptionKey:NSLocalizedStringWithDefaultValue(RNDBindingFailedErrorKey, nil, errorBundle, @"Unbinding Error", @"Unbinding Error"),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundErrorKey, nil, errorBundle, @"The binding controller is not bound.", @"The binding controller is not bound."),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedStringWithDefaultValue(RNDObjectIsBoundRecoverySuggestionErrorKey, nil, errorBundle, @"The binding controller is not bound. An unbind message has been sent to the controller's binders.", @"Attempted to unbind the binding controller.")
                                                       }];
            *error = internalError;
        }
        return result;
    }
    
    result = [self.binders unbind:&internalError];

    _bound = NO;
    return result;
}

- (void)unbind {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    [_coordinatorLock lock];
    [self unbindCoordinatedObjects:nil];
    [_coordinatorLock unlock];
    dispatch_semaphore_signal(_syncCoordinator);
}

- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error {
    dispatch_semaphore_wait(_syncCoordinator, DISPATCH_TIME_FOREVER);
    [_coordinatorLock lock];
    BOOL result = [self unbindCoordinatedObjects:error];
    [_coordinatorLock unlock];
    dispatch_semaphore_signal(_syncCoordinator);
    return result;
}

@end
