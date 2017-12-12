//
//  RNDPatternedStringProcessor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/8/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingProcessor.h"

@interface RNDPatternedStringProcessor : RNDBindingProcessor

@property (strong, readwrite, nullable) NSString *patternTemplate;

@end
