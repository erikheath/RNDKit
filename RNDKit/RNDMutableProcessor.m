//
//  RNDMutableProcessor.m
//  RNDKit
//
//  Created by Erikheath Thomas on 6/30/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMutableProcessor.h"


@implementation RNDMutableProcessor

@dynamic processConcurrently;
@dynamic processInReverseOrder;
@dynamic directives;

#pragma mark - Property Redefinition

- (void)setProcessConcurrently:(BOOL)processConcurrently {
    _processConcurrently = processConcurrently;
}

- (void)setProcessInReverseOrder:(BOOL)processInReverseOrder {
    _processInReverseOrder = processInReverseOrder;
}


#pragma mark - Initialization

- (instancetype)init {
    // REQUIRED
    if ((self = [super init]) == nil) { return nil; }
    _directives = [NSMutableArray new];
    
    // OPTIONAL
    _processConcurrently = NO;
    _processInReverseOrder = NO;
    
    return self;
}

-(instancetype)initWithDirectives:(NSArray<NSDictionary<NSString *,NSString *> *> *)directives executionOptions:(NSEnumerationOptions)options {
    // REQUIRED
    if ((self = [super init]) == nil) { return nil; }
    if ((_directives = [[NSMutableArray alloc] initWithArray:directives copyItems:YES]) == nil) { return nil; }
    
    // OPTIONAL
    _processConcurrently = NSEnumerationConcurrent & options;
    _processInReverseOrder = NSEnumerationReverse & options;
    
    return self;
}


#pragma mark - NSSecureCoding

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    // REQUIRED
    if ((self = [super init]) == nil) { return nil; }
    if ((_directives = [aDecoder decodeObjectOfClass:[NSMutableArray class]
                                              forKey:@"_directives"]) == nil) { return nil; }
    
    // OPTIONAL
    _processConcurrently = [aDecoder decodeIntegerForKey:@"_processConcurrently"];
    _processInReverseOrder = [aDecoder decodeIntegerForKey:@"_processInReverseOrder"];
    
    return  self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_directives forKey:@"_directives"];
    [aCoder encodeBool:_processConcurrently forKey:@"_processConcurrently"];
    [aCoder encodeBool:_processInReverseOrder forKey:@"_processInReverseOrder"];
}

#pragma mark - Key Value Coding

- (void)insertObject:(NSDictionary *)object inDirectivesAtIndex:(NSUInteger)index {
    [_directives insertObject:object atIndex:index];
}

- (void)insertDirectives:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    [_directives insertObjects:array atIndexes:indexes];
}

- (void)removeObjectFromDirectivesAtIndex:(NSUInteger)index {
    [_directives removeObjectAtIndex:index];
}

- (void)removeDirectivesAtIndexes:(NSIndexSet *)indexes {
    [_directives removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectInDirectivesAtIndex:(NSUInteger)index withObject:(id)object {
    [_directives replaceObjectAtIndex:index withObject:object];
}

- (void)replaceDirectivesAtIndexes:(NSIndexSet *)indexes withDirectives:(NSArray *)array {
    [_directives replaceObjectsAtIndexes:indexes withObjects:array];
}


#pragma mark - Behavior

- (void)addObject:(NSDictionary<NSString *,NSString *> *)directive {
    if (directive == nil) { return; }
    [_directives addObject:directive];
}

- (void)removeObject:(NSDictionary<NSString *,NSString *> *)directive {
    if (directive == nil) { return; }
    [_directives removeObject:directive];
}


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[RNDMutableProcessor allocWithZone:zone] initWithDirectives:_directives executionOptions:(_processConcurrently ? NSEnumerationConcurrent : 0) | (_processInReverseOrder ? NSEnumerationReverse : 0)];
}


@end
