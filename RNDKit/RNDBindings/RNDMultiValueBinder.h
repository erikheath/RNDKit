//
//  RNDMultiValueBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinder.h"

@interface RNDMultiValueBinder : RNDBinder

@property (readonly) BOOL isAndedValue;

- (id _Nullable)logicalValue:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
