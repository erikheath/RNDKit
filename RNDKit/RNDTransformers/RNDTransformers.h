//
//  RNDTransformers.h
//  RNDKit
//
//  Created by Erikheath Thomas on 6/13/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#ifndef RNDTransformers_h
#define RNDTransformers_h

//////////////////////////////////////////////////
/////////////////// GEOHASHING ///////////////////
//////////////////////////////////////////////////
#import "RNDGeohash/RNDCoordinateToGeohashTransformer.h"
#import "RNDGeohash/RNDGeohashToCoordinateTransformer.h"
#import "RNDGeohash/GeoHash.h"
#import "RNDGeohash/GHArea.h"
#import "RNDGeohash/GHNeighbors.h"
#import "RNDGeohash/GHRange.h"
//////////////////////////////////////////////////
//////////////////////////////////////////////////


//////////////////////////////////////////////////
//////////////// OBJECT TO STRING ////////////////
//////////////////////////////////////////////////
#import "RNDObjectFromString/RNDCLLocationFromStringTransformer.h"
#import "RNDObjectFromString/RNDUUIDFromUUIDString.h"
#import "RNDObjectFromString/RNDFontFromString.h"
#import "RNDObjectFromString/RNDURLFromString.h"
#import "RNDObjectFromString/RNDDateFromString.h"
#import "RNDObjectFromString/RNDDateFromNumber.h"
#import "RNDObjectFromString/RNDImageFromData.h"
//////////////////////////////////////////////////
//////////////////////////////////////////////////


#endif /* RNDTransformers_h */
