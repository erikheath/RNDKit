//
//  RNDGeohash10FromJSONCoordinateStringTransformer.m
//  RNDKit
//
//  Created by Erikheath Thomas on 6/23/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDGeohash10FromJSONCoordinateStringTransformer.h"
#import <CoreLocation/CoreLocation.h>
#import "GeoHash.h"
#import "GHArea.h"
#import "GHRange.h"

@implementation RNDGeohash10FromJSONCoordinateStringTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if (value == nil || [value isKindOfClass:[NSString class]] == NO) {
        return nil;
    }
    NSError *error = nil;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (JSONObject == nil ||
        [JSONObject isKindOfClass:[NSArray class]] == NO ||
        ((NSArray *)JSONObject).count != 2) { return nil; }
    
    CLLocationDegrees latitude = [((NSArray *)JSONObject).firstObject doubleValue];
    CLLocationDegrees longitude = [((NSArray *)JSONObject)[1] doubleValue];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
    if (CLLocationCoordinate2DIsValid(location) == NO) { return nil; }
    return [GeoHash hashForLatitude:location.latitude
                          longitude:location.longitude
                             length:8];
}

@end
