//
//  RNDCoordinatedArray.h
//  RNDKit
//
//  Created by Erikheath Thomas on 2/8/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingProtocolsCategories/RNDBindingObject.h"

@interface RNDCoordinatedArray<ObjectType> : NSMutableArray <RNDBindingObject>

@property (nonnull, strong, readonly) dispatch_semaphore_t syncCoordinator;
@property (strong, readonly, nonnull) NSRecursiveLock *coordinatorLock;

@end
