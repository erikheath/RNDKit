//
//  RNDBindingInfo.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindingInfo.h"
#import "RNDBinderSet.h"

@interface RNDBindingInfo()

@property (readwrite, nullable) NSArray<NSAttributeDescription *> *bindingOptionsInfo;
@property (readwrite, nonnull) RNDBinderType bindingType;
@property (readwrite, nonnull) RNDBinderName bindingName;
@property (readwrite) NSAttributeType bindingValueType;
@property (readwrite, assign, nullable) Class bindingValueClass;
@property (readwrite, nullable) NSArray<RNDBinderName> *excludedBindingsWhenActive;
@property (readwrite, nullable) NSArray<RNDBinderName> *requiredBindingsWhenActive;
@property (readwrite, nonnull) NSString *bindingKey;
@property (readwrite, nullable) NSDictionary<RNDBindingMarker, id> *defaultPlaceholders;

@end

@implementation RNDBindingInfo

static NSMutableDictionary *_bindingAdaptors;
static NSMutableDictionary *_manifestDictionary;

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

+ (void)initialize {
    [super initialize];
    
    // Get the bindings info from archived objects. This would be interesting because
    // it is the direction of how the actual binding instances (the adaptors et al) will
    // be handled at runtime.
    
    // The strategy is to search every bundle at runtime and coalesce all of the .rndbindingset resource files. The
    // resource files may be in other frameworks, your app, etc. If they're locatable by the bundle loading system,
    // they will be found.
    
    // Once found, the manifest of each rndbindingset will be merged, providing a lookup table for dynamic loading.
    // When a binding adaptor is requested using the identifier associated with a class, it will be loaded
    // into memory if it is not already via the decoding initializer and then returned to the caller.
    
    // Part of this search process should be asynchronous.
    
    _bindingAdaptors = [[NSMutableDictionary alloc] init];
    
    NSArray *bindingPathsArray = [NSBundle allBundles];
    
    NSMutableArray *manifestArray = [[NSMutableArray alloc] init];
    for (NSBundle *bundle in bindingPathsArray) {
        [manifestArray addObjectsFromArray:[bundle URLsForResourcesWithExtension:@"rndbindingmanifest" subdirectory:nil]];
        for (NSURL *url in manifestArray) {
            [_manifestDictionary addEntriesFromDictionary:(NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfURL:url]]];
            NSString *bindingSetKey;
            if ((bindingSetKey = _manifestDictionary[@"RNDLoadOnInitialize"]) != nil) {
                NSURL *initialURL = [NSURL URLWithString: _manifestDictionary[bindingSetKey]];
                NSDictionary *initialAdaptors = [NSDictionary dictionaryWithDictionary:(NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfURL:initialURL]]];
                [_bindingAdaptors addEntriesFromDictionary:initialAdaptors];
                [_manifestDictionary removeObjectForKey:@"RNDLoadOnInitialize"];
            }
        }
    }
    
}

+ (RNDBindingAdaptor *)adaptorForBindingIdentifier:(NSString *)bindingIdentifier {
    if (_bindingAdaptors[bindingIdentifier] != nil) {
        return _bindingAdaptors[bindingIdentifier];
    }
    NSString *bindingSetKey = [[bindingIdentifier componentsSeparatedByString:@"."] firstObject];
    NSURL *bindingURL = [NSURL URLWithString: _manifestDictionary[bindingSetKey]];
    [_bindingAdaptors addEntriesFromDictionary:[NSDictionary dictionaryWithDictionary:(NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfURL:bindingURL]]]];
    
    return _bindingAdaptors[bindingIdentifier];
}


@end
