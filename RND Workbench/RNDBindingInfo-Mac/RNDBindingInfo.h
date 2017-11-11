//
//  RNDBindingInfo.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RNDBindingConstants.h"
#import "RNDBinder.h"

// The job of this class is to read in the binding info plist
// and provide an object that describes the default options for
// a binding.

#pragma mark - RNDBinding Class Declaration
@interface RNDBindingInfo: NSObject

@property (readonly, nullable) NSArray<NSAttributeDescription *> *bindingOptionsInfo;
@property (readonly, nonnull) RNDBinderType bindingType;
@property (readonly, nonnull) RNDBinderName bindingName;
@property (readonly) NSAttributeType bindingValueType;
@property (readonly, assign, nullable) Class bindingValueClass;
@property (readonly, nullable) NSArray<RNDBinderName> *excludedBindingsWhenActive;
@property (readonly, nullable) NSArray<RNDBinderName> *requiredBindingsWhenActive;
@property (readonly, nonnull) NSString *bindingKey;
@property (readonly, nullable) NSDictionary<RNDBindingMarker, id> *defaultPlaceholders;

+ (NSDictionary<RNDBinderName, RNDBinder *> * _Nonnull)bindersForBindingIdentifier:(NSString * _Nonnull)bindingIdentifier error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
