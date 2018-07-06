//
//  RNDProcessor.m
//  RNDKit
//
//  Created by Erikheath Thomas on 6/30/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDProcessor.h"
#import "RNDMutableProcessor.h"
#import "RNDValuePathExtensions.h"

@implementation RNDProcessor

static NSMutableDictionary *registeredProcessors;

@synthesize directives = _directives;
@synthesize processConcurrently = _processConcurrently;
@synthesize processInReverseOrder = _processInReverseOrder;


#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[RNDProcessor allocWithZone:zone] initWithDirectives:_directives executionOptions:(_processConcurrently ? NSEnumerationConcurrent : 0) | (_processInReverseOrder ? NSEnumerationReverse : 0)];
}


#pragma mark - NSMutableCopying

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    return [[RNDMutableProcessor allocWithZone:zone] initWithDirectives:_directives executionOptions:(_processConcurrently ? NSEnumerationConcurrent : 0) | (_processInReverseOrder ? NSEnumerationReverse : 0)];
}


#pragma mark - NSKeyValueCoding

- (NSUInteger)countOfDirectives {
    return [((NSArray *)_directives) count];
}

- (id)objectInDirectivesAtIndex:(NSUInteger)index {
    return [_directives objectAtIndex:index];
}

- (NSArray *)directivesAtIndexes:(NSIndexSet *)indexes {
    return [_directives objectsAtIndexes:indexes];
}

- (void)getDirectives:( NSDictionary  __unsafe_unretained  * _Nonnull * _Nonnull )buffer range:(NSRange)inRange {
    [_directives getObjects:buffer range:inRange];
}

#pragma mark - Initialization

+ (void)initialize {
    [super initialize];
    if (self == [RNDProcessor self]) {
        registeredProcessors = [NSMutableDictionary new];
    }
}

-(instancetype)initWithDirectives:(NSArray<NSDictionary<NSString *,NSString *> *> *)directives executionOptions:(NSEnumerationOptions)options {
    // REQUIRED
    if ((self = [super init]) == nil) { return nil; }
    if ((_directives = [[NSArray alloc] initWithArray:directives copyItems:YES]) == nil) { return nil; }
    
    // OPTIONAL
    _processConcurrently = NSEnumerationConcurrent & options;
    _processInReverseOrder = NSEnumerationReverse & options;

    return self;
}


#pragma mark - NSSecureCoding

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    // REQUIRED
    if ((self = [super init]) == nil) { return nil; }
    if ((_directives = [aDecoder decodeObjectOfClass:[NSArray class]
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

+ (BOOL)supportsSecureCoding {
    return YES;
}


#pragma mark - Fast Enumeration

- (NSUInteger)countByEnumeratingWithState:(nonnull NSFastEnumerationState *)state objects:(id  _Nullable __unsafe_unretained * _Nonnull)buffer count:(NSUInteger)len {
    return [_directives countByEnumeratingWithState:state
                                            objects:buffer
                                              count:len];
}


#pragma mark - Processing Behavior
- (id)process:(id)target {
    
    [_context setObject:target forKey:@"RNDTarget"];
    for (NSDictionary *dictionary in _directives) {
        NSString *ekp = [[dictionary allValues] firstObject];
        NSString *contextKey = [[dictionary allKeys] firstObject];
        id result = [_context valueForExtendedKeyPath:ekp];
        [_context setObject:(result != nil ? result : [NSNull null]) forKey:contextKey];
    }

    return _context;
}


#pragma mark - Registration Management

+ (BOOL)registerProcessor:(RNDProcessor *)processor withName:(NSString *)name {
    
    
    
    return YES;

}


+ (BOOL)unregisterProcessorWithName:(NSString *)name {
    
    return YES;

}

+ (RNDProcessor *)processorWithName:(NSString *)name {
    
    return nil;
}

@end
