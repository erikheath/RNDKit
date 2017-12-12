//
//  RNDInvocationProcessor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/4/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "RNDBindingProcessor.h"

@protocol RNDBindableObject;

@interface RNDInvocationProcessor : RNDBindingProcessor

@property (strong, readwrite, nullable) NSString *bindingSelectorString;

@end
