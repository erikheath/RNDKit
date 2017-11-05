//
//  RNDBinderDelegate.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/1/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RNDBinderDelegate <NSObject>

@optional
- (void)valueOfBindingObject:(id _Nonnull)bindingObject
                  willChange:(NSDictionary<NSKeyValueChangeKey,id> * _Nonnull)change;

- (void)valueOfBindingObject:(id _Nonnull)bindingObject
                   didChange:(NSDictionary<NSKeyValueChangeKey,id> * _Nonnull)change;

- (void)valueOfBinderObject:(id)binderObject
                 willChange:(NSDictionary<NSKeyValueChangeKey,id> *)change;

- (void)valueOfBinderObject:(id)binderObject
                  didChange:(NSDictionary<NSKeyValueChangeKey,id> *)change;

- (void)binderShouldUpdateObserverObject:(id)observer
                               withValue:(id)value forKey:(NSString *)key;

- (id)binderWillUpdateObserverObject:(id)observer
                           withValue:(id)value forKey:(NSString *)key;

- (void)binderDidUpdateObserverObject:(id)observer
                            withValue:(id)value forKey:(NSString *)key;

- (void)binderShouldUpdateObservedObject:(id)observer
                               withValue:(id)value forKey:(NSString *)key;

- (id)binderWillUpdateObservedObject:(id)observer
                           withValue:(id)value forKey:(NSString *)key;

- (void)binderDidUpdateObservedObject:(id)observer
                            withValue:(id)value forKey:(NSString *)key;

@end
