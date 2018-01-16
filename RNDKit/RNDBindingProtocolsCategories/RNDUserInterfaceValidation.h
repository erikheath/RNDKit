//
//  RNDUserInterfaceValidation.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Protocol implemented by validated objects */

@protocol RNDValidatedUserInterfaceItem <NSObject>
@property (readonly, nullable) SEL action;
@property (readonly) NSInteger tag;
@end

/* Protocol implemented by validator objects */
@protocol RNDUserInterfaceValidations <NSObject>
- (BOOL)validateUserInterfaceItem:(id<RNDValidatedUserInterfaceItem> _Nonnull)item;
@end

