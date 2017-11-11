//
//  RNDBinderSet.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/27/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNDBinderSet: NSObject <NSCoding>

@property(nonnull, readonly) NSString *binderSetIdentifier;
@property(nonnull, readonly) NSDictionary *binders;


- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aCoder NS_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

- (BOOL)bind:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (BOOL)unbind:(NSError * _Nullable __autoreleasing * _Nullable)error;


@end
