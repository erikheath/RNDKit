//
//  NSString+RNDStringExtensions.m
//  RNDKit
//
//  Created by Erikheath Thomas on 5/24/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "NSString+RNDStringExtensions.h"

@implementation NSString (RNDStringExtensions)

- (instancetype)stringWithSubstitutions:(id)substitutions {
    NSString *newString = self;

    for (NSString *key in substitutions) {
        newString = [newString stringByReplacingOccurrencesOfString:key
                                             withString:substitutions[key]
                                                options:0
                                                  range:NSMakeRange(0, newString.length)];
    }
    
    return newString;
}

@end
