//
//  RNDValuePathExtensions.h
//  RNDKit
//
//  Created by Erikheath Thomas on 5/23/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

//void initializeValuePathExtensions( void );

@interface NSObject(RNDValuePathExtensions)

- (nullable id)valueForExtendedKeyPath:(NSString *)keyPath;

@end
