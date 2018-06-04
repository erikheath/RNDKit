//
//  RNDValuePathExtensions.m
//  RNDKit
//
//  Created by Erikheath Thomas on 5/23/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDValuePathExtensions.h"
#import "NSString+RNDStringExtensions.h"
#import <objc/runtime.h>


static IMP _originalValueForKeyPathMethod = NULL;

@implementation RNDValuePathExtensions

- (nullable id)valueForKeyPath:(NSString *)keyPath {

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[(][^\)]*[)]|([.])"
                                                                           options:NSRegularExpressionCaseInsensitive|NSRegularExpressionUseUnicodeWordBoundaries
                                                                             error:nil];
    
    NSString *extractedKey = nil;
    NSString *nextKeyPath = nil;
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:keyPath
                                                                 options:0
                                                                   range:NSMakeRange(0, keyPath.length)];
    if (matches.count != 0) {
        for (NSTextCheckingResult *match in matches) {
            if (match.numberOfRanges > 0) {
                extractedKey = [keyPath substringToIndex:[match rangeAtIndex:1].location - 1];
                nextKeyPath = [keyPath substringFromIndex:[match rangeAtIndex:1].location + 1];
                break;
            }
        }
    } else {
        extractedKey = keyPath;
    }
    
    id input = self;
    
    if ([extractedKey hasPrefix:@"@"] == NO) {
        input = [input valueForKey:extractedKey];
        return nextKeyPath != nil ? [input valueForKeyPath:nextKeyPath] : input;
    } else {
        NSArray<NSString *> *operatorStringArray = [extractedKey componentsSeparatedByString:@"("];
        NSString *formatString = operatorStringArray.count > 1 ? [operatorStringArray[1] substringToIndex:operatorStringArray[1].length - 1] : nil;
        if (formatString == nil) {
            return [input originalValueForKeyPath:keyPath];
        }
        SEL selector = NSSelectorFromString([operatorStringArray.firstObject stringByAppendingFormat:@"%@", @"UsingFormat:subsequentKeyPath:"]);
        return [input performSelector:selector withObject:formatString];
        
    }
    
    return nil;
}

- (nullable id)originalValueForKeyPath:(NSString *)keyPath {
    
    return nil;
}


/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

- (id)composeUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    BOOL isDictionary = [self isKindOfClass:[NSDictionary class]];
    id newCollection = isDictionary ? [NSMutableDictionary new] : [NSMutableArray new];
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        for (id object in self) {
            id testObject = isDictionary ? ((NSDictionary *)self)[object] : object;
            NSString *value = [format stringWithSubstitutionsVariables:testObject];
            if (isDictionary) {
                [newCollection setObject:value forKey:object];
            } else {
                [newCollection addObject:value];
            }
        }
    } else {
        newCollection = [format stringWithSubstitutionsVariables:self];
    }

    return keyPath == nil ? newCollection : [newCollection valueForKeyPath:keyPath];
}

- (id)filterUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    BOOL isDictionary = [self isKindOfClass:[NSDictionary class]];
    id newCollection = isDictionary ? [NSMutableDictionary new] : [NSMutableArray new];
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        for (id object in self) {
            id testObject = isDictionary ? ((NSDictionary *)self)[object] : object;
            BOOL result = [predicate evaluateWithObject:object];
            if (result) {
                if (isDictionary) {
                    [newCollection setObject:testObject forKey:object];
                } else {
                    [newCollection addObject:object];
                }
            }
        }
        newCollection = isDictionary ? [NSDictionary dictionaryWithDictionary:newCollection] : [NSArray arrayWithArray:newCollection];
    } else {
        newCollection = [predicate evaluateWithObject:self] ? self : nil;
    }
    return keyPath == nil ? newCollection : [newCollection valueForKeyPath:keyPath];
}

- (id)combineUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSArray *keyPathArray = [format componentsSeparatedByString:@","];
    NSMutableDictionary *newCollection = [NSMutableDictionary new];
    BOOL isDictionary = [self isKindOfClass:[NSDictionary class]];
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        for (id object in self) {
            id testObject = isDictionary ? ((NSDictionary *)self)[object] : object;
            id key = [testObject valueForKeyPath:keyPathArray[0]];
            id value = nil;
            if (keyPathArray.count > 2) {
                NSMutableArray *array = [NSMutableArray array];
                for (NSUInteger position = 1; position < keyPathArray.count; position++) {
                    [array addObject:[testObject valueForKeyPath:keyPathArray[position]]];
                }
                value = array;
            } else {
                value = [testObject valueForKeyPath:keyPathArray[1]];
            }
            [newCollection setObject:value forKey:key];
        }
    } else {
        id key = [self valueForKeyPath:keyPathArray[0]];
        id value = nil;
        if (keyPathArray.count > 2) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSUInteger position = 1; position < keyPathArray.count; position++) {
                [array addObject:[self valueForKeyPath:keyPathArray[position]]];
            }
            value = array;
        } else {
            value = [self valueForKeyPath:keyPathArray[1]];
        }
        [newCollection setObject:value forKey:key];
    }
    
    return keyPath == nil ? newCollection : [newCollection valueForKeyPath:keyPath];
}

- (id)mapUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    
    NSExpression *expression;
    BOOL isDictionary = [self isKindOfClass:[NSDictionary class]];
    id newCollection = isDictionary ? [NSMutableDictionary new] : [NSMutableArray new];
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        for (id object in self) {
            id testObject = isDictionary ? ((NSDictionary *)self)[object] : object;
            id value = [expression expressionValueWithObject:self context:testObject];
            if (isDictionary) {
                [newCollection setObject:value forKey:object];
            } else {
                [newCollection addObject:value];
            }
        }
    } else {
          newCollection = [expression expressionValueWithObject:self context:nil];
    }
    return keyPath == nil ? newCollection : [newCollection valueForKeyPath:keyPath];
}

- (id)foldUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSExpression *expression;
    BOOL isDictionary = [self isKindOfClass:[NSDictionary class]];
    id newCollection = isDictionary ? [NSMutableDictionary new] : [NSMutableArray new];
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
    for (id object in self) {
        id testObject = isDictionary ? ((NSDictionary *)self)[object] : object;
        id value = [expression expressionValueWithObject:newCollection context:testObject];
        if (isDictionary) {
            [newCollection setObject:value forKey:object];
        } else {
            [newCollection addObject:value];
        }
    }
    } else {
        newCollection = [expression expressionValueWithObject:newCollection context:nil];
    }
    return keyPath == nil ? newCollection : [newCollection valueForKeyPath:keyPath];
 }

@end
