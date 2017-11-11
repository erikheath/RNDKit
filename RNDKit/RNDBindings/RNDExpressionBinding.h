//
//  RNDExpressionBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinding.h"

@interface RNDExpressionBinding : RNDBinding

@property (strong, readonly, nonnull) NSRegularExpression *expression;
@property (strong, readonly, nonnull) NSString *replacementTemplate;

@end
