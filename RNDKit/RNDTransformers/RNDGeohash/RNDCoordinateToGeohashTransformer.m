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

- (id)transformedValue:(id)value {
    if (value == nil || [value isKindOfClass:[NSValue class]] == NO || CLLocationCoordinate2DIsValid(((NSValue *)value).MKCoordinateValue) == NO) {
        return nil;
    }
    CLLocationCoordinate2D location = ((NSValue *)value).MKCoordinateValue;
    return [GeoHash hashForLatitude:location.latitude
                                            longitude:location.longitude
                                               length:8];
}

@end
