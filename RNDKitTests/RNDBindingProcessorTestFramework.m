//
//  RNDBindingProcessorTestFramework.m
//  RNDKitTests
//
//  Created by Erikheath Thomas on 12/18/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "RNDBindingProcessorTestFramework.h"

@implementation RNDBindingProcessorTestFramework

+ (RNDBindingProcessor *)processorWithProfile:(NSString *)profileName {
    SEL profileSelector = NSSelectorFromString([@"profile" stringByAppendingString:profileName]);
    return [self performSelector:profileSelector];
}

+ (RNDBindingProcessor *)profileA {
    return [[RNDBindingProcessor alloc] init];
}

+ (RNDBindingProcessor *)profileB {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:[NSObject new] forKey:@"testProperty"];
    RNDBindingProcessor *profile = [[RNDBindingProcessor alloc] init];
    profile.observedObject = observedObject;
    profile.observedObjectKeyPath = @"testProperty";
    profile.monitorsObservedObject = YES;
    
    return profile;
}

+ (RNDBindingProcessor *)profileC {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:@"propertyValue" forKey:@"testProperty"];
    NSMutableDictionary *observedController = [NSMutableDictionary dictionary];
    [observedController setObject:observedObject forKey:@"testController"];
    
    RNDBindingProcessor *profile = [[RNDBindingProcessor alloc] init];
    profile.observedObject = observedController;
    profile.observedObjectKeyPath = @"testProperty";
    profile.controllerKey = @"testController";
    profile.monitorsObservedObject = YES;
    profile.bindingName = @"RNDTestBinding";
    
    return profile;
}

+ (RNDPatternedStringProcessor *)profileD {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:[NSObject new] forKey:@"testProperty"];
    NSMutableDictionary *observedController = [NSMutableDictionary dictionary];
    [observedController setObject:observedObject forKey:@"testController"];
    
    RNDPatternedStringProcessor *profile = [[RNDPatternedStringProcessor alloc] init];
    profile.observedObject = observedController;
    profile.observedObjectKeyPath = @"testProperty";
    profile.controllerKey = @"testController";
    profile.monitorsObservedObject = YES;
    profile.bindingName = @"RNDTestBinding";
    profile.patternTemplate = @"Hello";
    profile.argumentName = @"$ARG1";
    
    return profile;
}

+ (RNDPatternedStringProcessor *)profileE {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:[NSObject new] forKey:@"testProperty"];
    NSMutableDictionary *observedController = [NSMutableDictionary dictionary];
    [observedController setObject:observedObject forKey:@"testController"];
    
    RNDPatternedStringProcessor *profile = [[RNDPatternedStringProcessor alloc] init];
    profile.observedObject = observedController;
    profile.observedObjectKeyPath = @"testProperty";
    profile.controllerKey = @"testController";
    profile.monitorsObservedObject = YES;
    profile.bindingName = @"RNDTestBinding";
    profile.patternTemplate = @"World";
    profile.argumentName = @"$ARG2";
    
    return profile;
}

+ (RNDPatternedStringProcessor *)profileF {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:[NSObject new] forKey:@"testProperty"];
    NSMutableDictionary *observedController = [NSMutableDictionary dictionary];
    [observedController setObject:observedObject forKey:@"testController"];
    
    RNDPatternedStringProcessor *profile = [[RNDPatternedStringProcessor alloc] init];
    profile.observedObject = observedController;
    profile.observedObjectKeyPath = @"testProperty";
    profile.controllerKey = @"testController";
    profile.monitorsObservedObject = YES;
    profile.bindingName = @"RNDTestBinding";
    profile.patternTemplate = @"$ARG1 $ARG2!";
    
    return profile;
}

+ (RNDPredicateProcessor *)profileG {
    NSMutableDictionary *observedObject = [NSMutableDictionary dictionary];
    [observedObject setObject:[NSObject new] forKey:@"testProperty"];
    NSMutableDictionary *observedController = [NSMutableDictionary dictionary];
    [observedController setObject:observedObject forKey:@"testController"];
    
    RNDPredicateProcessor *profile = [[RNDPredicateProcessor alloc] init];
    profile.observedObject = observedController;
    profile.observedObjectKeyPath = @"testProperty";
    profile.controllerKey = @"testController";
    profile.monitorsObservedObject = YES;
    profile.bindingName = @"RNDTestBinding";
    profile.predicateFormatString = @"'Hello World!' = $ARG3";
    
    return profile;
}

+ (RNDRegExProcessor *)profileH {
    RNDRegExProcessor *profile = [[RNDRegExProcessor alloc] init];
    profile.bindingName = @"RNDTestBinding";
    profile.regExTemplate = @"(Hello)(.*)";
    profile.replacementTemplate = @"My$2";
    
    return profile;
}

+ (RNDExpressionProcessor *)profileI {
    RNDExpressionProcessor *profile = [[RNDExpressionProcessor alloc] init];
    profile.bindingName = @"RNDTestBinding";
    profile.expressionTemplate = @"now()";
    return profile;
}

+ (RNDInvocationProcessor *)profileJ {
    RNDInvocationProcessor *profile = [[RNDInvocationProcessor alloc] init];
    profile.bindingName = @"RNDTestBinding";
    profile.bindingSelectorString = @"stringByAppendingString:";
    return profile;
}

@end
