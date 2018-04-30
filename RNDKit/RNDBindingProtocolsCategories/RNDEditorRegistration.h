//
//  RNDEditorRegistration.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNDEditor.h"

@protocol RNDEditorRegistration <NSObject>

@optional

- (void)editorDidBeginEditing:(id<RNDEditor> _Nonnull)editor;

- (void)editorDidEndEditing:(id<RNDEditor> _Nonnull)editor;

- (void)editor:(id<RNDEditor> _Nonnull)editor didBeginEditingValueAtKeyPath:(NSString * _Nonnull)keyPath;

- (void)editor:(id<RNDEditor> _Nonnull)editor didEndEditingValueAtKeyPath:(NSString * _Nonnull)keyPath;

@end
