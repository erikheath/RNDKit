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

+ (NSArray<NSString *> * _Nonnull)RNDBindingNames;
+ (NSArray<NSString *> * _Nonnull)RNDBindingOptions;
+ (NSArray<NSAttributeDescription *> * _Nonnull)bindingOptionsInfoForBindingName:(RNDBindingName _Nonnull )bindingName;
+ (RNDBindingInfo * _Nullable)bindingInfoForBindingName:(RNDBindingName _Nonnull )bindingName;
+ (void)setDefaultPlaceholder:(nullable id)placeholder forMarker:(RNDBindingMarker _Nonnull )marker withBinding:(RNDBindingName _Nonnull )bindingName;
+ (nullable id)defaultPlaceholderForMarker:(RNDBindingMarker _Nonnull )marker withBinding:(RNDBindingName _Nonnull )bindingName;

@end
