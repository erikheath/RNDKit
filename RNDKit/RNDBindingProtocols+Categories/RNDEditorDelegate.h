//
//  RNDEditorDelegate.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RNDEditorDelegate <NSObject>

- (void)boundEditor:(id<RNDEditor>)editor didCommit:(BOOL)didCommit contextInfo:(void *)contextInfo;

@end

