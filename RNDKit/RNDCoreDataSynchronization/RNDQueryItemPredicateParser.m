//
//  RNDQueryItemPredicateParser.m
//  RNDKit
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDQueryItemPredicateParser.h"

@implementation RNDQueryItemPredicateParser

- (NSString *)keyValuePairAssigner {
    if (_keyValuePairAssigner == nil) {
        _keyValuePairAssigner = @"=";
    }
    return _keyValuePairAssigner;
}

- (NSString *)keyValuePairDelimiter {
    if (_keyValuePairDelimiter == nil) {
        _keyValuePairDelimiter = @"&";
    }
    return _keyValuePairDelimiter;
}

- (NSString *)beginSubGroupDelimiter {
    if (_beginSubGroupDelimiter == nil) {
        _beginSubGroupDelimiter = @"";
    }
    return _beginSubGroupDelimiter;
}

- (NSString *)endSubGroupDelimiter {
    if (_endSubGroupDelimiter == nil) {
        _endSubGroupDelimiter = @"";
    }
    return _endSubGroupDelimiter;
}

- (NSArray <NSURLQueryItem *> *)queryItemsForPredicateRepresentation:(NSPredicate *)predicate {
    
    NSString *queryString = [predicate isKindOfClass:[NSCompoundPredicate class]] ? [self queryStringForCompoundPredicate:(NSCompoundPredicate *)predicate] : [self queryStringForComparisonPredicate:(NSComparisonPredicate *)predicate];
    
    NSString *queryURLString = [@"http://www.test.com?" stringByAppendingString:queryString];
    NSURLComponents *queryComponents = [NSURLComponents componentsWithString:queryURLString];
    
    return queryComponents.queryItems;
}

- (NSString *)queryStringForCompoundPredicate:(NSCompoundPredicate *)predicate {
    
    NSMutableString *queryString = [NSMutableString string];
    
    for (NSPredicate *subPredicate in predicate.subpredicates) {
        
        NSString *subPredicateQueryString = nil;

        if ([subPredicate isKindOfClass:[NSCompoundPredicate class]] == YES) {
            subPredicateQueryString = [self queryStringForCompoundPredicate:(NSCompoundPredicate *)subPredicate];
            subPredicateQueryString = [NSString stringWithFormat:@"%@%@%@", self.beginSubGroupDelimiter, subPredicateQueryString, self.endSubGroupDelimiter];
        } else if ([subPredicate isKindOfClass:[NSComparisonPredicate class]] == YES) {
            subPredicateQueryString = [self queryStringForComparisonPredicate:((NSComparisonPredicate *)subPredicate)];
        }
        
        if (queryString.length > 0) {
            [queryString appendFormat:@"%@%@", self.keyValuePairDelimiter, subPredicateQueryString];
        } else {
            [queryString appendFormat:@"%@", subPredicateQueryString];
        }
    }
    
    return queryString;
}

- (NSString *)queryStringForComparisonPredicate:(NSComparisonPredicate *)predicate {
    NSString *constraint = predicate.leftExpression.keyPath;
    NSString *value = predicate.rightExpression.constantValue;
    NSString *queryComponent = [NSString stringWithFormat:@"%@%@%@", constraint, self.keyValuePairAssigner, value];
    return [queryComponent stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
}

@end
