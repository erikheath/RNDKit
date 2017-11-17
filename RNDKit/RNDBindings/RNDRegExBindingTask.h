//
//  RNDExpressionBinder.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindingTask.h"

@interface RNDRegExBindingTask : RNDBindingTask

@property (strong, readonly, nonnull) NSRegularExpression *expression;
@property (strong, readonly, nonnull) NSString *replacementTemplate;

@end
