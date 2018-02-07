//
//  RNDCoordinatedDictionary.h
//  RNDKit
//
//  Created by Erikheath Thomas on 2/6/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDBindingProtocolsCategories/RNDBindingObject.h"

@interface RNDCoordinatedDictionary : NSMutableDictionary <RNDBindingObject>

@property (strong, nullable, readonly) dispatch_queue_t coordinator;
@property (strong, nullable, readonly) NSUUID *coordinatorQueueIdentifier;
@property (nonnull, strong, readonly) dispatch_semaphore_t syncCoordinator;

@end
