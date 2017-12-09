//
//  RNDURLResourceBinding.m
//  RNDKit
//
//  Created by Erikheath Thomas on 11/30/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDURLResourceBinding.h"
#import "../RNDBindings/RNDPredicateBinding.h"
#import <objc/runtime.h>

@interface RNDURLResourceBinding()

@property (strong, nullable, readwrite) NSURLComponents *resourceURLComponents;

@end

@implementation RNDURLResourceBinding

#pragma mark - Properties
@synthesize resourceURLTemplate = _resourceURLTemplate;

- (void)setResourceURLTemplate:(NSString * _Nullable)resourceURLTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _resourceURLTemplate = resourceURLTemplate;
    });
}

- (NSString * _Nullable)resourceURLTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _resourceURLTemplate;
    });
    return localObject;
}

@synthesize baseURLTemplate = _baseURLTemplate;

- (void)setBaseURLTemplate:(NSString * _Nullable)baseURLTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _baseURLTemplate = baseURLTemplate;
    });
}

- (NSString * _Nullable)baseURLTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _resourceURLTemplate;
    });
    return localObject;
}

@synthesize fragmentTemplate = _fragmentTemplate;

- (void)setFragmentTemplate:(NSString * _Nullable)fragmentTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _baseURLTemplate = fragmentTemplate;
    });
}

- (NSString * _Nullable)fragmentTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _fragmentTemplate;
    });
    return localObject;
}

@synthesize hostTemplate = _hostTemplate;

- (void)setHostTemplate:(NSString * _Nullable)hostTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _hostTemplate = hostTemplate;
    });
}

- (NSString * _Nullable)hostTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _hostTemplate;
    });
    return localObject;
}

@synthesize passwordTemplate = _passwordTemplate;

- (void)setPasswordTemplate:(NSString * _Nullable)passwordTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _passwordTemplate = passwordTemplate;
    });
}

- (NSString * _Nullable)passwordTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _passwordTemplate;
    });
    return localObject;
}


@synthesize pathTemplate = _pathTemplate;

- (void)setPathTemplate:(NSString * _Nullable)pathTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _pathTemplate = pathTemplate;
    });
}

- (NSString * _Nullable)pathTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _pathTemplate;
    });
    return localObject;
}


@synthesize portTemplate = _portTemplate;

- (void)setPortTemplate:(NSString * _Nullable)portTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _portTemplate = portTemplate;
    });
}

- (NSString * _Nullable)portTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _portTemplate;
    });
    return localObject;
}


@synthesize queryTemplate = _queryTemplate;

- (void)setQueryTemplate:(NSString * _Nullable)queryTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _queryTemplate = queryTemplate;
    });
}

- (NSString * _Nullable)queryTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _queryTemplate;
    });
    return localObject;
}


@synthesize schemeTemplate = _schemeTemplate;

- (void)setSchemeTemplate:(NSString * _Nullable)schemeTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _schemeTemplate = schemeTemplate;
    });
}

- (NSString * _Nullable)schemeTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _schemeTemplate;
    });
    return localObject;
}


@synthesize userNameTemplate = _userNameTemplate;

- (void)setUserNameTemplate:(NSString * _Nullable)userNameTemplate {
    dispatch_barrier_sync(self.syncQueue, ^{
        if (self.isBound == YES) { return; }
        _userNameTemplate = userNameTemplate;
    });
}

- (NSString * _Nullable)userNameTemplate {
    id __block localObject = nil;
    dispatch_sync(self.syncQueue, ^{
        localObject = _userNameTemplate;
    });
    return localObject;
}



#pragma mark - Calculated (Transient) Properties
- (id _Nullable)bindingObjectValue {
    id __block objectValue = nil;
    
    dispatch_sync(self.syncQueue, ^{
        
        if (self.isBound == NO) {
            objectValue = nil;
            return;
        }
        
        if (((NSNumber *)self.evaluator.bindingObjectValue).boolValue == NO ) {
            objectValue = nil;
            return;
        }
        
        NSMutableString *replacableresourceURLTemplate = _resourceURLTemplate != nil ? [NSMutableString stringWithString:_resourceURLTemplate] : nil;
        
        NSMutableString *replacableBaseURLTemplate = _baseURLTemplate != nil ? [NSMutableString stringWithString:_baseURLTemplate] : nil;
        
        NSMutableString *replacableFragmentTemplate = _fragmentTemplate != nil ? [NSMutableString stringWithString:_fragmentTemplate] : nil;
        
        NSMutableString *replacableHostTemplate = _hostTemplate != nil ? [NSMutableString stringWithString:_hostTemplate] : nil;
        
        NSMutableString *replacablePasswordTemplate = _passwordTemplate != nil ? [NSMutableString stringWithString:_passwordTemplate] : nil;
        
        NSMutableString *replacablePathTemplate = _pathTemplate != nil ? [NSMutableString stringWithString:_pathTemplate] : nil;
        
        NSMutableString *replacablePortTemplate = _portTemplate != nil ? [NSMutableString stringWithString:_portTemplate] : nil;
        
        NSMutableString *replacableQueryTemplate = _queryTemplate != nil ? [NSMutableString stringWithString:_queryTemplate] : nil;
        
        NSMutableString *replacableSchemeTemplate = _schemeTemplate != nil ? [NSMutableString stringWithString:_schemeTemplate] : nil;
        
        NSMutableString *replacableUserNameTemplate = _userNameTemplate != nil ? [NSMutableString stringWithString:_userNameTemplate] : nil;
        
        for (RNDBinding *binding in self.bindingArguments) {
            [replacableresourceURLTemplate replaceOccurrencesOfString:binding.argumentName
                                                   withString:binding.bindingObjectValue
                                                      options:0
                                                        range:NSMakeRange(0, replacableresourceURLTemplate.length)];
            [replacableBaseURLTemplate replaceOccurrencesOfString:binding.argumentName
                                                           withString:binding.bindingObjectValue
                                                              options:0
                                                                range:NSMakeRange(0, replacableBaseURLTemplate.length)];
            [replacableFragmentTemplate replaceOccurrencesOfString:binding.argumentName
                                                           withString:binding.bindingObjectValue
                                                              options:0
                                                                range:NSMakeRange(0, replacableFragmentTemplate.length)];
            [replacableHostTemplate replaceOccurrencesOfString:binding.argumentName
                                                           withString:binding.bindingObjectValue
                                                              options:0
                                                                range:NSMakeRange(0, replacableHostTemplate.length)];
            [replacablePasswordTemplate replaceOccurrencesOfString:binding.argumentName
                                                           withString:binding.bindingObjectValue
                                                              options:0
                                                                range:NSMakeRange(0, replacablePasswordTemplate.length)];
            [replacablePathTemplate replaceOccurrencesOfString:binding.argumentName
                                                           withString:binding.bindingObjectValue
                                                              options:0
                                                                range:NSMakeRange(0, replacablePathTemplate.length)];
            [replacablePortTemplate replaceOccurrencesOfString:binding.argumentName
                                                           withString:binding.bindingObjectValue
                                                              options:0
                                                                range:NSMakeRange(0, replacablePortTemplate.length)];
            [replacableQueryTemplate replaceOccurrencesOfString:binding.argumentName
                                                           withString:binding.bindingObjectValue
                                                              options:0
                                                                range:NSMakeRange(0, replacableQueryTemplate.length)];
            [replacableSchemeTemplate replaceOccurrencesOfString:binding.argumentName
                                                           withString:binding.bindingObjectValue
                                                              options:0
                                                                range:NSMakeRange(0, replacableSchemeTemplate.length)];
            [replacableUserNameTemplate replaceOccurrencesOfString:binding.argumentName
                                                           withString:binding.bindingObjectValue
                                                              options:0
                                                                range:NSMakeRange(0, replacableUserNameTemplate.length)];

        }
        
        for (NSString *runtimeKey in self.runtimeArguments) {
            [replacableresourceURLTemplate replaceOccurrencesOfString:runtimeKey
                                                   withString:self.runtimeArguments[runtimeKey]
                                                      options:0
                                                        range:NSMakeRange(0, replacableresourceURLTemplate.length)];
            [replacableBaseURLTemplate replaceOccurrencesOfString:runtimeKey
                                                       withString:self.runtimeArguments[runtimeKey]
                                                          options:0
                                                            range:NSMakeRange(0, replacableBaseURLTemplate.length)];
            [replacableFragmentTemplate replaceOccurrencesOfString:runtimeKey
                                                        withString:self.runtimeArguments[runtimeKey]
                                                           options:0
                                                             range:NSMakeRange(0, replacableFragmentTemplate.length)];
            [replacableHostTemplate replaceOccurrencesOfString:runtimeKey
                                                    withString:self.runtimeArguments[runtimeKey]
                                                       options:0
                                                         range:NSMakeRange(0, replacableHostTemplate.length)];
            [replacablePasswordTemplate replaceOccurrencesOfString:runtimeKey
                                                        withString:self.runtimeArguments[runtimeKey]
                                                           options:0
                                                             range:NSMakeRange(0, replacablePasswordTemplate.length)];
            [replacablePathTemplate replaceOccurrencesOfString:runtimeKey
                                                    withString:self.runtimeArguments[runtimeKey]
                                                       options:0
                                                         range:NSMakeRange(0, replacablePathTemplate.length)];
            [replacablePortTemplate replaceOccurrencesOfString:runtimeKey
                                                    withString:self.runtimeArguments[runtimeKey]
                                                       options:0
                                                         range:NSMakeRange(0, replacablePortTemplate.length)];
            [replacableQueryTemplate replaceOccurrencesOfString:runtimeKey
                                                     withString:self.runtimeArguments[runtimeKey]
                                                        options:0
                                                          range:NSMakeRange(0, replacableQueryTemplate.length)];
            [replacableSchemeTemplate replaceOccurrencesOfString:runtimeKey
                                                      withString:self.runtimeArguments[runtimeKey]
                                                         options:0
                                                           range:NSMakeRange(0, replacableSchemeTemplate.length)];
            [replacableUserNameTemplate replaceOccurrencesOfString:runtimeKey
                                                        withString:self.runtimeArguments[runtimeKey]
                                                           options:0
                                                             range:NSMakeRange(0, replacableUserNameTemplate.length)];
        }
        
        // Create the base componenets
        if (replacableresourceURLTemplate != nil) {
            NSURL *composedURL = [NSURL URLWithString:replacableresourceURLTemplate relativeToURL:[NSURL URLWithString:replacableBaseURLTemplate]];
            _resourceURLComponents = [NSURLComponents componentsWithURL:composedURL resolvingAgainstBaseURL:YES];
        } else {
            _resourceURLComponents = [[NSURLComponents alloc] init];
        }
        
        // Fill in any specializations
        _resourceURLComponents.fragment = replacableFragmentTemplate != nil ? replacableFragmentTemplate : _resourceURLComponents.fragment;
        _resourceURLComponents.host = replacableHostTemplate != nil ? replacableHostTemplate : _resourceURLComponents.host;
        _resourceURLComponents.password = replacablePasswordTemplate != nil ? replacablePasswordTemplate : _resourceURLComponents.password;
        _resourceURLComponents.path = replacablePathTemplate != nil ? replacablePathTemplate : _resourceURLComponents.path;
        _resourceURLComponents.port = replacablePortTemplate != nil ? [NSNumber numberWithInteger:[replacablePortTemplate integerValue]] : _resourceURLComponents.port;
        _resourceURLComponents.query = replacableQueryTemplate != nil ? replacableQueryTemplate : _resourceURLComponents.query;
        _resourceURLComponents.scheme = replacableSchemeTemplate != nil ? replacableSchemeTemplate : _resourceURLComponents.scheme;
        _resourceURLComponents.user = replacableUserNameTemplate != nil ? replacableUserNameTemplate: _resourceURLComponents.user;

        id replacableObjectValue = [_resourceURLComponents URL];
        
        if (replacableObjectValue == nil) {
            objectValue = self.nilPlaceholder != nil ? self.nilPlaceholder.bindingObjectValue : replacableObjectValue;
            if (objectValue != nil) { return; }
        }
        
        objectValue = self.valueTransformer != nil ? [self.valueTransformer transformedValue:replacableObjectValue] : replacableObjectValue;
        
    });
    
    return objectValue;
}

#pragma mark - Object Lifecycle
- (instancetype)init {
    return [super init];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init]) != nil) {
        
        uint propertyCount;
        objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
            if ([propertyName isEqualToString:@"resourceURLComponents"]) { continue; }
            [self setValue:[aDecoder decodeObjectForKey:propertyName] forKey:propertyName];
        }
        
        if (propertyCount > 0) {
            free(properties);
        }
        
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    uint propertyCount;
    objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        NSString * propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
        if ([propertyName isEqualToString:@"resourceURLComponents"]) { continue; }
        [aCoder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
    }
    
    if (propertyCount > 0) {
        free(properties);
    }
}

#pragma mark - Binding Management

@end
