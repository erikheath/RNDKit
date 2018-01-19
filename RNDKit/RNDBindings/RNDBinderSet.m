//
//  RNDBinderSet.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/27/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

// TODO: Define Implementation

#import "RNDBinderSet.h"
#import "../RNDBindingConstants.h"

@implementation RNDBinderSet

@synthesize binderSetIdentifier = _binderSetIdentifier;
@synthesize binders = _binders;
@synthesize binderSetNamespace = _binderSetNamespace;

#pragma mark - Object Lifecycle
- (instancetype _Nullable)init {
    if ((self = [super init]) != nil) {
        _binders = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aCoder {
    if ((self = [super init]) != nil) {
        _binders = [aCoder decodeObjectForKey:@"binders"];
        _binderSetIdentifier = [aCoder decodeObjectForKey:@"binderSetIdentifier"];
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

@end
