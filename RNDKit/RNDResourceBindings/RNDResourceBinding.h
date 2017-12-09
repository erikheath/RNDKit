//
//  RNDResource.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/28/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../RNDBindings/RNDBinding.h"

@interface RNDResourceBinding: RNDBinding

@property (strong, nullable, readwrite) NSString *resourceNamespace;
@property (strong, nonnull, readwrite) NSString *resourceIdentifier;
@property (strong, nullable, readwrite) id resourceObjectValue;
@property (strong, nonnull, readonly) NSMutableDictionary *resourceArguments;

+ (RNDResourceBinding * _Nonnull)resourceForInfo:(NSDictionary *_Nonnull)resourceInfo error:(NSError * __autoreleasing _Nullable * _Nullable)error;

@end
