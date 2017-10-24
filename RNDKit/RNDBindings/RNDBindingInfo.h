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

@class RNDBindingAdaptor;

#pragma mark - RNDBinding Class Declaration
@interface RNDBindingInfo: NSObject

@property (readonly, nullable) NSArray<NSAttributeDescription *> *bindingOptionsInfo;
@property (readonly, nonnull) RNDBindingType bindingType;
@property (readonly, nonnull) RNDBindingName bindingName;
@property (readonly) NSAttributeType bindingValueType;
@property (readonly, assign, nullable) Class bindingValueClass;
@property (readonly, nullable) NSArray<RNDBindingName> *excludedBindingsWhenActive;
@property (readonly, nullable) NSArray<RNDBindingName> *requiredBindingsWhenActive;
@property (readonly, nonnull) NSString *bindingKey;
@property (readonly, nullable) NSDictionary<RNDBindingMarker, id> *defaultPlaceholders;

+ (RNDBindingAdaptor * _Nullable)adaptorForBindingIdentifier:(NSString * _Nonnull)bindingIdentifier;

@end
