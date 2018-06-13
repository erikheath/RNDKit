//
//  RNDCLCoordinateFromString.m
//  RNDKit
//
//  Created by Erikheath Thomas on 4/29/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDCLLocationFromStringTransformer.h"

@implementation RNDCLLocationFromStringTransformer

+ (Class)transformedValueClass {
    return [CLLocation class];
}
+ (BOOL)allowsReverseTransformation {
    return YES;
}

/**
 Takes an NSString value containing comma separated values and returns a CLCoordinate object.

 If two arguments are specified:
 the first a latitude
 the second a longitude
 
 If more than two but less than six arguments are specified:
 the first a latitude
 the second a longitude
 the third horizontal accuracy
 the fourth vertical accuracy
 the fifth argument is the timestamp as an NSExpression compatible Date format. The timestamp expression must be in single or double quotes.
 
 If more than five arguments are specified:
 the first a latitude
 the second a longitude
 the third horizontal accuracy
 the fourth vertical accuracy
 the fifth argument is the course
 the sixth argument is the speed
 the seventh argument is the timestamp as an NSExpression compatible Date format. The timestamp expression must be in single or double quotes.
 
 Any unspecified values will be treated as zero. If the timestamp is unspecified, the current date will be used.

 @param value An NSString represenation of a location.
 @return A CLLocation object, or nil if the transformation failed.
 */
- (id)transformedValue:(id)value {
    CLLocationDegrees latitude = 0.0, longitude = 0.0;
    CLLocationDistance altitude = 0.0;
    CLLocationAccuracy horizontal = 0.0, vertical = 0.0;
    CLLocationDirection course = 0.0;
    CLLocationSpeed speed = 0.0;
    NSDate *timestamp = [NSDate date];
    
    if (value == nil || ![value isKindOfClass:[NSString class]]) return nil;
    
    NSString *locationString = (NSString *)value;
    NSUInteger counter = 0;
    for (NSUInteger position = 0; position < locationString.length; ) {
        NSRange result = [locationString rangeOfString:@","
                              options:NSCaseInsensitiveSearch
                                range:NSMakeRange(position, locationString.length - position)];
        switch (counter) {
            case 0: {
                latitude = [[locationString substringWithRange:NSMakeRange(1, result.location - position - 1)] doubleValue];
                position = result.location + 1;
                break;
            }
            case 1: {
                if (result.location == NSNotFound) {
                    longitude = [[locationString substringWithRange:NSMakeRange(position, locationString.length - position)] doubleValue];
                    break;
                }
                longitude = [[locationString substringWithRange:NSMakeRange(position, result.location - position - 1)] doubleValue];
                position = result.location + 1;
                break;
            }
            case 2: {
                altitude = [[locationString substringWithRange:NSMakeRange(position, result.location - position)] doubleValue];
                position = result.location + 1;
                break;
            }
            case 3: {
                horizontal = [[locationString substringWithRange:NSMakeRange(position, result.location - position)] doubleValue];
                position = result.location + 1;
                break;
            }
            case 4: {
                vertical = [[locationString substringWithRange:NSMakeRange(position, result.location - position)] doubleValue];
                NSString *testString = [locationString substringWithRange:NSMakeRange(result.location, 2)];
                position = [testString isEqualToString:@",'"] || [testString isEqualToString:@",\""] ? result.location : result.location + 1;
                break;
            }
            case 5: {
                NSString *testString = [locationString substringWithRange:NSMakeRange(result.location, 2)];
                if ([testString isEqualToString:@",'"] == YES || [testString isEqualToString:@",\""]) {
                    NSString *dateString = [locationString substringWithRange:NSMakeRange(position + 2, locationString.length - position - 3)];
                    NSDate *date = [[NSExpression expressionWithFormat:@"CAST(%@,'NSDate')", dateString] expressionValueWithObject:nil context:nil];
                    timestamp = [date isKindOfClass:[NSDate class]] == YES ? date : timestamp;
                    result = NSMakeRange(NSNotFound, 0);
                } else {
                    course = [[locationString substringWithRange:NSMakeRange(position, result.location - position)] doubleValue];
                    position = result.location + 1;
                }
                break;
            }
            case 6: {
                speed = [[locationString substringWithRange:NSMakeRange(position, result.location - position)] doubleValue];
                NSString *testString = [locationString substringWithRange:NSMakeRange(result.location, 2)];
                position = [testString isEqualToString:@",'"] || [testString isEqualToString:@",\""] ? result.location: result.location + 1;
                break;
            }
            case 7: {
                NSString *testString = [locationString substringWithRange:NSMakeRange(result.location, 2)];
                if ([testString isEqualToString:@",'"] == YES || [testString isEqualToString:@",\""]) {
                    NSString *dateString = [locationString substringWithRange:NSMakeRange(position + 2, locationString.length - position - 3)];
                    NSDate *date = [[NSExpression expressionWithFormat:@"CAST(%@,'NSDate')", dateString] expressionValueWithObject:nil context:nil];
                    timestamp = [date isKindOfClass:[NSDate class]] == YES ? date : timestamp;
                    result = NSMakeRange(NSNotFound, 0);
                }
                break;
            }
            default: {
                break;
            }
        }
        if (result.location == NSNotFound) { break; }
        counter++;
    }

    
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(latitude, longitude);

    return [[CLLocation alloc] initWithCoordinate:coordinates
                                         altitude:altitude
                               horizontalAccuracy:horizontal
                                 verticalAccuracy:vertical
                                           course:course
                                            speed:speed
                                        timestamp:timestamp];
}


/**
 Produces a comma separated string representation of a CLLocation.

 @param value A CLLocation object.
 @return An NSString object, or nil is the transformation failed.
 */
- (id)reverseTransformedValue:(id)value {
    if (value == nil || ![value isKindOfClass:[CLLocation class]]) return nil;
    CLLocation *location = (CLLocation *)value;
    
    return [NSString stringWithFormat:@"{%lf,%lf},%lf,%lf,%lf,%lf,%lf,'%@'", location.coordinate.latitude, location.coordinate.longitude, location.altitude, location.horizontalAccuracy, location.verticalAccuracy, location.course, location.speed, location.timestamp];
}

@end
