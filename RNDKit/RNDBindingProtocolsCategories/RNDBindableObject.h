//
//  RNDBindableObject.h
//  RNDKit
//
//  Created by Erikheath Thomas on 12/22/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RNDBinderSet;

@protocol RNDBindableObject <NSObject>

@property (strong, readwrite, nullable) NSString *bindingIdentifier;
@property (strong, readonly, nullable) NSMutableArray * bindingDestinations;
@property (strong, readonly, nullable) NSMutableDictionary *bindings;

@end
