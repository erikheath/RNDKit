//
//  RNDController.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/2/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDController.h"

static NSString *alwaysPresentsApplicationModalAlertsKey = @"alwaysPresentsApplicationModalAlertsKey";
static NSString *refreshesAllModelKeysKey = @"refreshesAllModelKeysKey";
static NSString *multipleObservedModelObjectsKey = @"multipleObservedModelObjectsKey";

@implementation RNDController

- (instancetype)init {
    if ((self = [super init]) != nil) {
        self.editorSet = [NSMutableSet<RNDEditor> new];
        self.declaredKeySet = [NSMutableSet<NSString *> new];
        self.dependentKeyToModelKeyTable = [NSMutableDictionary<NSString *, NSString *> new];
        self.modelKeyToDependentKeyTable = [NSMutableDictionary<NSString *, NSCountedSet<NSString *> *> new];
        self.modelKeysToRefreshEachTime = [NSMutableSet<NSString *> new];
    }
    return self;
}
- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super init]) != nil) {
        self.alwaysPresentsApplicationModalAlerts = [coder decodeBoolForKey:alwaysPresentsApplicationModalAlertsKey];
        self.refreshesAllModelKeys = [coder decodeBoolForKey:refreshesAllModelKeysKey];
        self.multipleObservedModelObjects = [coder decodeBoolForKey:multipleObservedModelObjectsKey];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeBool:self.alwaysPresentsApplicationModalAlerts forKey:alwaysPresentsApplicationModalAlertsKey];
    [aCoder encodeBool:self.refreshesAllModelKeys forKey:refreshesAllModelKeysKey];
    [aCoder encodeBool:self.multipleObservedModelObjects forKey:multipleObservedModelObjectsKey];
}


- (void)objectDidBeginEditing:(id<RNDEditor>)editor {
    [self.editorSet addObject:editor];
}

- (void)objectDidEndEditing:(id<RNDEditor>)editor {
    [self.editorSet removeObject:editor];
}

// Causes the controller to force its editors to discard any pending edits.
- (void)discardEditing {
    for (id<RNDEditor> editor in self.editorSet) {
        [editor discardEditing];
    }
    return;
}

// Causes the controller to force it editors to attempt to commit any pending edits.
- (BOOL)commitEditing {
    for (id<RNDEditor> editor in self.editorSet) {
        if ([editor commitEditing] == NO) {
            return NO;
        }
    }
    return YES;
}

// This method is for objects that have been registered with objectDidBeginEditing. This is not available for controllers.
- (void)commitEditingWithDelegate:(nullable id<RNDEditorDelegate>)delegate didCommitSelector:(nullable SEL)didCommitSelector contextInfo:(nullable void *)contextInfo {
    
    return;
}

// This method is for objects that have been registered with objectDidBeginEditing.
- (BOOL)commitEditingAndReturnError:(NSError * _Nullable __autoreleasing * _Nullable)error {
    return NO;
}

// This method is for actual editors to notify other editors.
- (void)editor:(nonnull id<RNDEditor>)editor didCommit:(BOOL)didCommit contextInfo:(nonnull void *)contextInfo {
    return;
}

@end

