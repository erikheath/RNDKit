//
//  NSObject+RNDObjectBinding.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/21/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindings/RNDBindings.h"

@interface NSObject (RNDObjectBinding) <RNDEditor>

@property (readonly, nullable) RNDBindingAdaptor *adaptor;

@end
