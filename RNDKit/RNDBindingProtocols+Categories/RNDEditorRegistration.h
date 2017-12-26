//
//  RNDEditorRegistration.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RNDEditor;

@protocol RNDEditorRegistration <NSObject>

@property (readonly, nonnull) NSSet<id<RNDEditor>> * editorSet;

- (void)objectDidBeginBoundEdit:(id<RNDEditor> _Nonnull)editor;

- (void)objectDidEndBoundEdit:(id<RNDEditor> _Nonnull)editor;

@end
