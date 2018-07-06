//
//  RNDGeohashToCoordinateTransformer.m
//  RNDKit
//
//  Created by Erikheath Thomas on 6/2/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDGeohashToCoordinateTransformer.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GeoHash.h"
#import "GHArea.h"
#import "GHRange.h"

@implementation RNDGeohashToCoordinateTransformer

+ (Class)transformedValueClass {
    return [NSValue class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    if (value == nil || [value isKindOfClass:[NSString class]] == NO ||
        [GeoHash verifyHash:value] == NO) {
        return nil;
    }
    GHArea *area = [GeoHash areaForHash:(NSString *)value];
    CLLocationDegrees latitude = area.latitude.max.doubleValue; // TODO: CONFIRM MATH
    CLLocationDegrees longitude = area.longitude.max.doubleValue; // TODO: CONFIRM MATH
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
    return [NSValue valueWithMKCoordinate:location];
}

@end
