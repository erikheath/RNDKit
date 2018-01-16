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

- (void)boundEditor:(id<RNDEditorDelegate>)editor didCommit:(BOOL)didCommit contextInfo:(void *)contextInfo error:(NSError **)error;

@end

