//
//  RNDObjectController.m
//  RNDKit
//
//  Created by Erikheath Thomas on 10/2/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDObjectController.h"
#import <objc/runtime.h>

#pragma mark -
@interface RNDSelection ()

@property (weak, nullable) RNDController *controller;

@end

#pragma mark -
@implementation RNDSelection

#pragma mark Object Lifecycle
- (instancetype)init {
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (self.controller != nil) {
        [invocation invokeWithTarget:self.controller];
    }
}

@end

#pragma mark -
@interface RNDObjectController ()

#pragma mark Instance Properties
@property id selected;

@end

#pragma mark -
@implementation RNDObjectController

#pragma mark Instance Properties

@synthesize objectClass = _objectClass, content = _content;

- (void)setObjectClass:(Class)objectClass {
    _objectClass = objectClass;
}

- (Class)objectClass {
    return _objectClass == nil? [NSMutableDictionary class] : _objectClass;
}

- (id)selection {
    RNDSelection *selectionObj = [[RNDSelection alloc] init];
    selectionObj.controller = self;
    return selectionObj;
}

- (NSArray *)selectedObjects {
    return @[_content];
}

- (NSString *)objectClassName {
    return NSStringFromClass(self.objectClass);
}


#pragma mark Class Properties

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}


#pragma mark Object Lifecycle

- (instancetype)init {
    return [self initWithContent:nil];
}

- (instancetype)initWithContent:(nullable id)content {
    if ((self = [super init]) != nil) {
        self.content = content;
        self.controllerType = RNDClassController;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder]) != nil) {
        self.content = [coder decodeObjectForKey:@"content"];
        self.automaticallyPreparesContent = [coder decodeBoolForKey:@"automaticallyPreparesContent"];
        self.controllerType = [coder decodeIntegerForKey:@"controllerType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeBool:self.automaticallyPreparesContent forKey:@"automaticallyPreparesContent"];
    [aCoder encodeInteger:self.controllerType forKey:@"controllerType"];
    
}

- (void)awakeFromNib {
    if (self.automaticallyPreparesContent == YES) {
        [self prepareContent];
    }
}

- (void)prepareContent {
    [self addObject:[self newObject]];
}


#pragma mark Content Management

- (id)newObject {
    return [[self.objectClass alloc] init];
}

- (IBAction)add:(nullable id)sender {
    [self addObject:[self newObject]];
}

- (IBAction)remove:(nullable id)sender {
    [self removeObject:self.content];
}

- (void)addObject:(id)object {
    self.content = object;
}

- (void)removeObject:(id)object {
    if (object == self.content) {
        self.content = nil;
    }
}


@end

#pragma mark -
@implementation RNDObjectController (NSKeyValueCoding)

#pragma mark KVC Base Overrides
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    return [self isAutomaticallySupportedKey:theKey] || [super automaticallyNotifiesObserversForKey:theKey];
}

+ (BOOL)isAutomaticallySupportedKey:(NSString *)theKey {
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"(canAdd)|(canRemove)|(content)|(isEditable)|(objectClass)|(selectedObjects)" options:NSRegularExpressionCaseInsensitive error:&error];
    if ([expression numberOfMatchesInString:theKey options:0 range:NSMakeRange(0, theKey.length)] == 1) {
        return YES;
    }
    return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    // Maps the incoming notification to a KVO notification for observers.

    // Determine what the change applied to: selection, selectedObjects, content.
    NSCountedSet *bindingKeyPaths = self.modelKeyToDependentKeyTable[keyPath];

    switch ([[change objectForKey:NSKeyValueChangeKindKey] integerValue]) {
        case NSKeyValueChangeSetting:
            for (NSString *bindingKeyPath in bindingKeyPaths) {
                [self willChangeValueForKey:bindingKeyPath];
                [self didChangeValueForKey:bindingKeyPath];
            }
            break;
        case NSKeyValueChangeInsertion:
        {
            NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            for (NSString *bindingKeyPath in bindingKeyPaths) {
                [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:bindingKeyPath];
                [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexSet forKey:bindingKeyPath];
            }
            break;
        }
        case NSKeyValueChangeRemoval:
        {
            NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            for (NSString *bindingKeyPath in bindingKeyPaths) {
                [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:bindingKeyPath];
                [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:bindingKeyPath];
            }
            break;
        }
        case NSKeyValueChangeReplacement:
        {
            NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            for (NSString *bindingKeyPath in bindingKeyPaths) {
                [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexSet forKey:bindingKeyPath];
                [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexSet forKey:bindingKeyPath];
            }
            break;
        }
        default:
            break;
    }
    
    
    return;
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    // Record the info necessary to register as an observer of the model for the specified key for the observer.
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
    NSString *modelKey = [self modelKeyPathFromBindingKeyPath:keyPath];
    [self.dependentKeyToModelKeyTable setObject:modelKey forKey: keyPath];
    NSCountedSet *dependentKeysSet = self.modelKeyToDependentKeyTable[modelKey] != nil ? self.modelKeyToDependentKeyTable[modelKey] : [[NSCountedSet alloc] initWithCapacity:5];
    [dependentKeysSet addObject:keyPath];
    [self.modelKeyToDependentKeyTable setObject:dependentKeysSet forKey:modelKey];
    [self.content addObserver:self forKeyPath:modelKey options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionPrior | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    [self removeObserver:observer forKeyPath:keyPath context:nil];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    // This should remove the entry for the observer, and therefore the observation of the model.
    [self.content removeObserver:self forKeyPath:[self modelKeyPathFromBindingKeyPath:keyPath] context:context];
    [super removeObserver:observer forKeyPath:keyPath context:context];
    
}


#pragma mark Key Utilities

- (id)targetForBindingKeyPath:(NSString *)bindingKeyPath {
    NSScanner *scanner = [[NSScanner alloc] initWithString:bindingKeyPath];
    NSString *result = [[NSString alloc] init];
    if ([scanner scanString:RNDBindingCurrentSelectionKeyPathComponent intoString:&result]) {
        return self.content;
    } else if ([scanner scanString:RNDBindingSelectedObjectsKeyPathComponent intoString:&result]) {
        return self.content;
    } else if ([scanner scanString:RNDBindingContentObjectKeyPathComponent intoString:&result]) {
        return self.content;
    }
    return self;
}

- (NSString *)modelKeyPathFromBindingKeyPath:(NSString *)bindingKeyPath {
    NSError *error = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"(content\.|selection\.|selectedObjects\.)(.*)" options:0 error:&error];
    NSTextCheckingResult *result = [expression matchesInString:bindingKeyPath options:NSMatchingAnchored range:NSMakeRange(0, bindingKeyPath.length)].firstObject;
    return (result != nil) && [result rangeAtIndex:2].location != NSNotFound ? [bindingKeyPath substringWithRange:[result rangeAtIndex:2]] : bindingKeyPath;
}

#pragma mark KVC Setters
- (void)setValue:(id)value forKey:(NSString *)key {
    [self setValue:value forKeyPath:key];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    [[self targetForBindingKeyPath:keyPath] setValue:value forKey:[self modelKeyPathFromBindingKeyPath:keyPath]];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    return; // Does nothing but does not crash.
}

- (void)setNilValueForKey:(NSString *)key {
    return; // Does nothing but does not crash.
}

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    for (NSString *key in keyedValues) {
        [[self targetForBindingKeyPath:key] setValue:keyedValues[key] forKeyPath:[self modelKeyPathFromBindingKeyPath:key]];
    }
}

#pragma mark KVC Getters

- (id)valueForKey:(NSString *)key {
    return [self valueForKeyPath:key];
}

- (id)valueForKeyPath:(NSString *)keyPath {
    id testObject = [self targetForBindingKeyPath:keyPath];
    return (testObject == self)? [super valueForKey:keyPath] : [[self targetForBindingKeyPath:keyPath] valueForKeyPath:[self modelKeyPathFromBindingKeyPath:keyPath]];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key {
    return [self mutableArrayValueForKeyPath:key];
}

- (NSMutableArray *)mutableArrayValueForKeyPath:(NSString *)keyPath {
    return [[self targetForBindingKeyPath:keyPath] mutableArrayValueForKey:[self modelKeyPathFromBindingKeyPath:keyPath]];
}

- (NSMutableSet *)mutableSetValueForKey:(NSString *)key {
    return [self mutableSetValueForKeyPath:key];
}

- (NSMutableSet *)mutableSetValueForKeyPath:(NSString *)keyPath {
    return [[self targetForBindingKeyPath:keyPath] mutableSetValueForKeyPath:[self modelKeyPathFromBindingKeyPath:keyPath]];
}

- (NSMutableOrderedSet *)mutableOrderedSetValueForKey:(NSString *)key {
    return [self mutableOrderedSetValueForKeyPath:key];
}

- (NSMutableOrderedSet *)mutableOrderedSetValueForKeyPath:(NSString *)keyPath {
    return [[self targetForBindingKeyPath:keyPath] mutableOrderedSetValueForKeyPath:[self modelKeyPathFromBindingKeyPath:keyPath]];
}

#pragma mark KVC Validators

- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue forKey:(NSString *)inKey error:(out NSError * _Nullable __autoreleasing *)outError {
    return [super validateValue:ioValue forKey:inKey error:outError];
}

- (BOOL)validateValue:(inout id  _Nullable __autoreleasing *)ioValue forKeyPath:(NSString *)inKeyPath error:(out NSError * _Nullable __autoreleasing *)outError {
    return [super validateValue:ioValue forKeyPath:inKeyPath error:outError];
}

@end


