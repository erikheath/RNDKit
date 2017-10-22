//
//  RNDController.h
//  RNDBindableObjects
//
//  Created by Erikheath Thomas on 6/29/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../RNDBindings/RNDBindings.h"


NS_ASSUME_NONNULL_BEGIN

@interface RNDController : NSObject <RNDEditor, RNDEditorRegistration, RNDEditorDelegate, NSCoding> { }

@property (readwrite) NSMutableSet<RNDEditor> *editorSet;
@property (readwrite) NSMutableSet<NSString *> *declaredKeySet;
@property (readwrite) NSMutableDictionary<NSString *, NSString *> *dependentKeyToModelKeyTable;
@property (readwrite) NSMutableDictionary<NSString *, NSCountedSet<NSString *> *> *modelKeyToDependentKeyTable;
@property (readwrite) NSMutableSet<NSString *> *modelKeysToRefreshEachTime;
@property (readwrite) BOOL alwaysPresentsApplicationModalAlerts;
@property (readwrite) BOOL refreshesAllModelKeys;
@property (readwrite) BOOL multipleObservedModelObjects;
@property (getter=isEditing, readwrite) BOOL editing;


- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (void)objectDidBeginEditing:(id<RNDEditor>)editor;
- (void)objectDidEndEditing:(id<RNDEditor>)editor;
- (void)discardEditing;
- (BOOL)commitEditing;
- (void)commitEditingWithDelegate:(nullable id)delegate didCommitSelector:(nullable SEL)didCommitSelector contextInfo:(nullable void *)contextInfo;

@end

NS_ASSUME_NONNULL_END
