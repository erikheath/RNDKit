//
//  RNDResponseProcessor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol RNDResponseProcessorDelegate <NSObject>



@end

@protocol RNDResponseProcessor <NSObject>

- (NSArray <NSString *> *)uniqueIdentifiersForEntity:(NSEntityDescription *)entity responseData:(NSData *)data error:(NSError **)error;

- (NSDictionary *)valuesForEntity:(NSEntityDescription *)entity responseData:(NSData *)responseData error:(NSError **)error;

- (NSDictionary <NSManagedObjectID *, NSDate *> *)lastUpdatesForEntity:(NSEntityDescription *)entity objectIDs:(NSArray <NSManagedObjectID *> *)objectIDs responseData:(NSData *)data error:(NSError **)error;


@end
