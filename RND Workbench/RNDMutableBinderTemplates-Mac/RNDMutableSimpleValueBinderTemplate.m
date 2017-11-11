//
//  RNDMutableSimpleValueBinderTemplate.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMutableSimpleValueBinderTemplate.h"

@interface RNDMutableSimpleValueBinderTemplate()

@property (nonnull, strong, readonly) NSMutableArray<RNDMutableBindingTemplate *> * bindingArray;

@end

@implementation RNDMutableSimpleValueBinderTemplate

#pragma mark - Properties

@synthesize bindingArray = _bindingArray;


- (NSArray<RNDMutableBindingTemplate *> *)bindings {
    return [NSArray arrayWithArray:self.bindingArray];
}

#pragma mark - Object Lifecycle

- (instancetype)initWithName:(RNDBinderName)binderName
                       error:(NSError * _Nullable __autoreleasing *)error {
    
    if ((self = [super initWithBinderName:binderName error:error]) == nil) {
        return nil;
    }

    _bindingArray = [[NSMutableArray alloc] initWithCapacity:1];

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]) == nil) {
        return nil;
    }
    
    _bindingArray = [aDecoder decodeObjectForKey:@"bindingArray"];

    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_bindingArray forKey:@"bindingArray"];
}

@end
