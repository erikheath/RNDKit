//
//  RNDBindingProcessorTestFramework.h
//  RNDKit
//
//  Created by Erikheath Thomas on 12/18/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RNDKit/RNDKit.h>
#import <objc/runtime.h>
#import <CoreData/CoreData.h>

@interface RNDBindingProcessorTestFramework: NSObject

+ (RNDBindingProcessor *)processorWithProfile:(NSString *)profileName;
+ (RNDBindingProcessor *)profileA;
+ (RNDBindingProcessor *)profileB;
+ (RNDBindingProcessor *)profileC;
+ (RNDPatternedStringProcessor *)profileD;
+ (RNDPatternedStringProcessor *)profileE;
+ (RNDPatternedStringProcessor *)profileF;
+ (RNDPredicateProcessor *)profileG;
+ (RNDRegExProcessor *)profileH;
+ (RNDExpressionProcessor *)profileI;
+ (RNDInvocationProcessor *)profileJ;
+ (RNDInvocationProcessor *)profileK;

@end
