//
//  RNDGeohashFromJSONRegionStringTransformer.m
//  RNDKit
//
//  Created by Erikheath Thomas on 6/24/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDGeohashFromJSONRegionStringTransformer.h"
#import <CoreLocation/CoreLocation.h>
#import "GeoHash.h"
#import "GHArea.h"
#import "GHRange.h"

@implementation RNDGeohashFromJSONRegionStringTransformer

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
    
    NSMutableArray<CLLocation *> *coordinateRegion = [NSMutableArray new];
    NSArray *locationArray = (NSArray *)JSONObject;
    for (NSArray *location in locationArray) {
        if ([location isKindOfClass:[NSArray class]] == NO ||
            location.count != 2) { return nil; }
        CLLocationDegrees latitude = [location.firstObject doubleValue];
        CLLocationDegrees longitude = [location[1] doubleValue];
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(latitude, longitude);
        if (CLLocationCoordinate2DIsValid(coordinates) == NO) { return nil; }
        [coordinateRegion addObject:[[CLLocation alloc] initWithCoordinate:coordinates
                                                                  altitude:0
                                                        horizontalAccuracy:0
                                                          verticalAccuracy:0
                                                                 timestamp:[NSDate date]]];
    }
    
    NSString *maxGeohash = [GeoHash hashForLatitude:coordinateRegion[0].coordinate.latitude
                                          longitude:coordinateRegion[0].coordinate.longitude
                                             length:10];
    NSString *minGeohash = [GeoHash hashForLatitude:coordinateRegion[1].coordinate.latitude
                                          longitude:coordinateRegion[1].coordinate.longitude
                                             length:10];
    
    NSString *commonHash = [maxGeohash commonPrefixWithString:minGeohash options:NSLiteralSearch];
    
    return commonHash;
}

@end
