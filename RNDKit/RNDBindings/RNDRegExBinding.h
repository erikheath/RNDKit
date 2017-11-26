//
//  RNDRegExBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBinding.h"

@interface RNDRegExBinding : RNDBinding

@property (strong, readwrite, nullable) NSString *regExTemplate;
@property (strong, readwrite, nullable) NSString *replacementTemplate;

@end
