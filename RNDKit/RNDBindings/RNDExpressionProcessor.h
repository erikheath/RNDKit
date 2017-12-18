//
//  RRNDExpressionProcessor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/9/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingProcessor.h"

@interface RNDExpressionProcessor: RNDBindingProcessor

@property (strong, readwrite, nullable) NSString *expressionTemplate;

@end

