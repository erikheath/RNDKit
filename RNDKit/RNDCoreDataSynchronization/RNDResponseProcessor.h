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

@interface RNDResponseProcessor: NSObject

@property (strong, nullable, nonatomic, readwrite) id responseProcesorDelegate;

- (NSArray <NSString *> *)uniqueIdentifiersForEntity:(NSEntityDescription *)entity responseData:(NSData *)data error:(NSError **)error;

@end
