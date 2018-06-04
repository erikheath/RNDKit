//
//  RNDCoordinateToGeohashTransformer.m
//  RNDKit
//
//  Created by Erikheath Thomas on 6/2/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

// Takes a coordinate pair and transforms to a geohash value.
// On reverse, takes a geohash and transforms to a coordinate pair.

#import "RNDCoordinateToGeohashTransformer.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GeoHash.h"
#import "GHArea.h"
#import "GHRange.h"


@implementation RNDCoordinateToGeohashTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    if (value == nil || [value isKindOfClass:[NSValue class]] == NO || CLLocationCoordinate2DIsValid(((NSValue *)value).MKCoordinateValue) == NO) {
        return nil;
    }
    CLLocationCoordinate2D location = ((NSValue *)value).MKCoordinateValue;
    return [GeoHash hashForLatitude:location.latitude
                                            longitude:location.longitude
                                               length:8];
}

- (id)reverseTransformedValue:(id)value {
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
