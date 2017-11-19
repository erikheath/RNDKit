//
//  RNDMutableBindingTemplate.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RNDMutableBindingTemplate;

@interface RNDMutableBinderTemplate : NSObject <NSCoding>

@property (strong, readwrite, nullable) RNDBinderName binderName;
@property (strong, readwrite, nullable) NSMutableArray<RNDMutableBindingTemplate *> * bindings;
@property (weak, readwrite, nullable) id observer;

- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)initWithBinderName:(RNDBinderName _Nonnull )binderName
                                       error:(NSError *__autoreleasing  _Nullable * _Nullable)error NS_DESIGNATED_INITIALIZER;
- (instancetype _Nullable)initWithCoder:(NSCoder * _Nonnull)aDecoder NS_DESIGNATED_INITIALIZER;
- (void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

@end
