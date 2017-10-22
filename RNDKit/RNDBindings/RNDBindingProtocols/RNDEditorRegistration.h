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

- (void)objectDidBeginEditing:(id<RNDEditor> _Nonnull)editor;

- (void)objectDidEndEditing:(id<RNDEditor> _Nonnull)editor;

@end
