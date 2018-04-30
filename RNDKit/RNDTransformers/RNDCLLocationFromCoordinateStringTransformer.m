//
//  RNDCLCoordinateFromString.m
//  RNDKit
//
//  Created by Erikheath Thomas on 4/29/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDCLLocationFromCoordinateStringTransformer.h"

@implementation RNDCLLocationFromCoordinateStringTransformer

+ (Class)transformedValueClass {
    return [CLLocation class];
}
+ (BOOL)allowsReverseTransformation {
    return YES;
}


/**
 Takes an NSString value containing two comma separated double values: the first a latitude, the second a longitude, and returns a CLCoordinate object.

 @param value An NSString represenation of a coodinate.
 @return A CLCoordinate object, or nil if the transformation failed.
 */
- (id)transformedValue:(id)value {
    CLLocationDegrees latitude, longitude;
    if (value == nil || ![value isKindOfClass:[NSString class]]) return nil;
    NSArray<NSString *> *coordinateArray = [(NSString *)value componentsSeparatedByString:@","];
    if (coordinateArray.count != 2) return nil;
    latitude = [coordinateArray[0] doubleValue];
    longitude = [coordinateArray[1] doubleValue];
    
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (id)reverseTransformedValue:(id)value {
    if (value == nil || ![value isKindOfClass:[CLLocation class]]) return nil;
    return [NSString stringWithFormat:@"%lf,%lf", ((CLLocation *)value).coordinate.latitude, ((CLLocation *)value).coordinate.longitude];
}

@end
