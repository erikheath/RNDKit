//
//  RNDDynamicBindingObject.h
//  RNDKit
//
//  Created by Erikheath Thomas on 1/18/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RNDDynamicBindingObject: NSObject

@property (strong, readwrite, nonnull) NSMutableArray<NSString*> *protocolIdentifiers;

@end
