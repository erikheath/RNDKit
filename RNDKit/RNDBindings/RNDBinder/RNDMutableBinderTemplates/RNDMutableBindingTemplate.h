//
//  RNDBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../../RNDBindingConstants.h"

@class RNDMutableBinderTemplate;
@class RNDBinder;
@class RNDBinding;

@interface RNDMutableBindingTemplate : NSObject <NSCoding>

@property (readwrite) BOOL monitorsObservedObject;
@property (strong, nonnull, readwrite) NSString *observedObjectBindingIdentifier;
@property (strong, nonnull, readwrite) NSString * observedKeyPath;
@property (weak, nullable, readwrite) RNDMutableBinderTemplate * binderTemplate;
@property (strong, nullable, readwrite) id nullPlaceholder;
@property (strong, nullable, readwrite) id multipleSelectionPlaceholder;
@property (strong, nullable, readwrite) id noSelectionPlaceholder;
@property (strong, nullable, readwrite) id notApplicablePlaceholder;
@property (strong, nullable, readwrite) NSPredicate *filterPredicate;
@property (strong, nullable, readwrite) NSString *argumentName;
@property (strong, nullable, readwrite) NSString *valueTransformerName;


+ (instancetype _Nullable)bindingForBinderTemplate:(RNDMutableBinderTemplate * _Nonnull)binderTemplate
               withObservedObjectBindingIdentifier:(NSString * _Nonnull )bindingIdentifier
                                           keyPath:(NSString *_Nonnull)keyPath
                                           options:(NSDictionary<RNDBindingOption, id> * _Nullable)options
                                             error:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable )initWithBinderTemplate:(RNDMutableBinderTemplate * _Nonnull)binderTemplate
                  observedObjectBindingIdentifier:(NSString * _Nonnull )bindingIdentifier
                                          keyPath:(NSString *_Nonnull)keyPath
                                          options:(NSDictionary<RNDBindingOption, id> * _Nullable)options
                                            error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aDecoder NS_DESIGNATED_INITIALIZER;

-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

- (void)binding:(NSCoder * _Nonnull)aCoder;


@end


// Bindings can read data from anywhere, Binders do the writing. Binders coordinate bindings.
