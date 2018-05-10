//
//  RNDQueryItemPredicateParser.h
//  RNDKit
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RNDQueryItemPredicateParser: NSObject

@property (strong, nonnull, nonatomic, readwrite) NSString *keyValuePairAssigner;

@property (strong, nonnull, nonatomic, readwrite) NSString *keyValuePairDelimiter;

@property (strong, nonnull, nonatomic, readwrite) NSString *beginSubGroupDelimiter;

@property (strong, nonnull, nonatomic, readwrite) NSString *endSubGroupDelimiter;

- (NSArray <NSURLQueryItem *> *)queryItemsForPredicateRepresentation:(NSPredicate *)predicate;

@end
