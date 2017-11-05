//
//  RNDBinderInfo.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/27/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"
#import "RNDBindingInfo.h"

@interface RNDBinderInfo: NSObject <NSCoding>

@property(nonnull, readonly) NSString *binderIdentifier;
@property(nonnull, readonly) NSDictionary *bindingInfo;

+ (instancetype)binderForIdentifier:(NSString *)binderIdentifier;
- (instancetype)initWithIdentifier:(NSString *)binderIdentifier;
- (instancetype)initWithCoder:(NSCoder *)aCoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
