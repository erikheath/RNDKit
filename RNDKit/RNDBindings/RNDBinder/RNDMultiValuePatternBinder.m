//
//  RNDMultiValuePatternBinder.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMultiValuePatternBinder.h"
#import "RNDBinding.h"

@interface RNDMultiValuePatternBinder ()

@end

@implementation RNDMultiValuePatternBinder

#pragma mark - Properties
@synthesize patternString = _patternString;

#pragma mark - Object Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) == nil) {
        return nil;
    }

    _patternString = [aDecoder decodeObjectForKey:@"patternString"];

    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_patternString forKey:@"patternString"];
}


#pragma mark - Binding Management




@end
