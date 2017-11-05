//
//  RNDMutableMultiValueBinderTemplate
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDMutableMultiValueBinderTemplate.h"

@interface RNDMutableMultiValueBinderTemplate ()

@property (nonnull, strong, readonly) NSMutableArray<RNDMutableBindingTemplate *> * bindingArray;

@end

@implementation RNDMutableMultiValueBinderTemplate

#pragma mark - Properties

@synthesize bindingArray = _bindingArray;


- (NSArray<RNDMutableBindingTemplate *> *)bindings {
    return [NSArray arrayWithArray:_bindingArray];
}


#pragma mark - Object Lifecycle

- (instancetype)initWithBinderName:(RNDBinderName)binderName
                             error:(NSError * _Nullable __autoreleasing *)error {
    
    if ((self = [super initWithBinderName:binderName error:error]) == nil) {
        return nil;
    }
    
    _bindingArray = [NSMutableArray array];
    
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
