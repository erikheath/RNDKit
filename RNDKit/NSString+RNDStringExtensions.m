//
//  NSString+RNDStringExtensions.m
//  RNDKit
//
//  Created by Erikheath Thomas on 5/24/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "NSString+RNDStringExtensions.h"

@implementation NSString (RNDStringExtensions)

- (instancetype)stringWithSubstitutionsVariables:(id)substitutions {
    NSString *newString = self;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[$](\\w*)\\b" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    
    NSUInteger matchCount = [regex numberOfMatchesInString:newString
                                                   options:0
                                                     range:NSMakeRange(0, newString.length)];
    for (NSUInteger position = 0; position < matchCount; position++) {
        NSTextCheckingResult *result = [regex firstMatchInString:newString
                                                         options:0
                                                           range:NSMakeRange(0, newString.length)];
        NSString *keyPath = [newString substringWithRange:[result rangeAtIndex:0]];
        NSString *newValue = [substitutions valueForKeyPath:keyPath];
        newString = [regex replacementStringForResult:result
                                 inString:newString
                                   offset:0
                                 template:newValue];
    }

    return newString;
}

@end
