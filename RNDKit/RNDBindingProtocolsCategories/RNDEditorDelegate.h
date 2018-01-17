//
//  RNDEditorDelegate.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RNDEditor;

@protocol RNDEditorDelegate <NSObject>

@required

- (void)boundEditor:(id<RNDEditorDelegate> _Nonnull)editor didCommit:(BOOL)didCommit contextInfo:(void * _Nullable)contextInfo error:(NSError * __autoreleasing _Nullable * _Nullable)error;

@optional

- (BOOL)editedValue:(id _Nullable)editedValue shouldChangeToValue:(id _Nullable)newValue fromDataSourceValue:(id _Nullable)dataSourceValue;
@end

