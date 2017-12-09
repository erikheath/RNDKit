//
//  RNDURLResource.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/29/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDResourceBinding.h"

@interface RNDURLResourceBinding: RNDResourceBinding

@property (strong, nullable, readwrite) NSString *resourceURLTemplate;
@property (strong, nullable, readwrite) NSString *baseURLTemplate;

// Components of the constructed URL. Setting these will override the resource and base URL Template
// parts. The two can be used together to create varying URLs at runtime.
@property (strong, nullable, readwrite) NSString *fragmentTemplate;
@property (strong, nullable, readwrite) NSString *hostTemplate;
@property (strong, nullable, readwrite) NSString *passwordTemplate;
@property (strong, nullable, readwrite) NSString *pathTemplate;
@property (strong, nullable, readwrite) NSString *portTemplate;
@property (strong, nullable, readwrite) NSString *queryTemplate;
@property (strong, nullable, readwrite) NSString *schemeTemplate;
@property (strong, nullable, readwrite) NSString *userNameTemplate;

@end
