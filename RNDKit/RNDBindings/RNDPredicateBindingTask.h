//
//  RNDPredicateBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/9/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNDPredicateBindingExpression: NSObject

@property (strong, readonly, nonnull) NSString *predicateFormatString;

- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;

-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

-(BOOL)evaluate:(NSMutableDictionary * _Nonnull)context;

@end
