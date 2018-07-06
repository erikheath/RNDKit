//
//  RNDValuePathExtensions.m
//  RNDKit
//
//  Created by Erikheath Thomas on 5/23/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDValuePathExtensions.h"
#import "NSString+RNDStringExtensions.h"
#import <objc/runtime.h>

@implementation NSObject(RNDValuePathExtensions)

#pragma mark - 
- (nullable id)valueForExtendedKeyPath:(NSString *)keyPath {

    NSString *extractedKey = nil;
    NSString *nextKeyPath = nil;

    NSUInteger matchedParenCounter = 0;
    NSRange searchRange;
    NSCharacterSet *startSet = [NSCharacterSet characterSetWithCharactersInString:@".@"];
    NSCharacterSet *parenSet = [NSCharacterSet characterSetWithCharactersInString:@"()"];
    
    NSRange startRange = [keyPath rangeOfCharacterFromSet:startSet];
    if (startRange.location != NSNotFound) {
        if ([[keyPath substringWithRange:startRange] isEqualToString:@"."]) {
            extractedKey = [keyPath substringToIndex:startRange.location];
            nextKeyPath = [keyPath substringFromIndex:startRange.location + 1];
        } else {
            searchRange = NSMakeRange(0, keyPath.length);
            do {
                searchRange = [keyPath rangeOfCharacterFromSet:parenSet
                                                       options:0
                                                         range:searchRange];
                // '(' add 1, ')' subtracts 1
                matchedParenCounter = [[keyPath substringWithRange:searchRange] isEqualToString:@"("] ? matchedParenCounter + 1 : matchedParenCounter - 1;
                searchRange = NSMakeRange(searchRange.location + 1, keyPath.length - searchRange.location - 1);
            } while (matchedParenCounter != 0);
            extractedKey = [keyPath substringToIndex:searchRange.location];
            if (searchRange.location < keyPath.length && [[keyPath substringWithRange:NSMakeRange(searchRange.location, 1)] isEqualToString:@"."]) {
                searchRange = NSMakeRange(searchRange.location + 1, searchRange.length - 1);
            }
            nextKeyPath = searchRange.location == keyPath.length ? nil : [keyPath substringFromIndex:searchRange.location];
        }
    } else {
        extractedKey = keyPath;
    }
    
    id input = self;
    
    if ([extractedKey hasPrefix:@"@"] == NO) {
        input = [input valueForKey:extractedKey];
        return nextKeyPath != nil ? [input valueForExtendedKeyPath:nextKeyPath] : input;
    } else {
        NSString *operator = nil;
        NSString *formatString = nil;
        NSRange location = [extractedKey rangeOfString:@"("];
        if (location.location == NSNotFound) {
            operator = [extractedKey substringWithRange:NSMakeRange(1, extractedKey.length - 1)];
        } else {
            operator = [extractedKey substringWithRange:NSMakeRange(1, location.location - 1)];
            formatString = [extractedKey substringWithRange:NSMakeRange(location.location + 1, extractedKey.length - 2 - location.location)];
            formatString = formatString.length > 0 ? formatString : nil;
        }
        SEL selector = NSSelectorFromString([operator stringByAppendingFormat:@"%@", @"UsingFormat:subsequentKeyPath:"]);
        return [input performSelector:selector withObject:formatString withObject:nextKeyPath];
    }
    
    return nil;
}

////////////////////////////////////////////////////////////////////////
///////////////////////// UTILITIES /////////////////////////
////////////////////////////////////////////////////////////////////////

- (NSArray <NSDictionary *> *)keyedValuePathsFromStringRepresentation:(NSString *)representation {
    NSString *extractedKey = nil;
    NSString *extractedValuePath = nil;
    NSMutableArray *keyedValuePaths = [NSMutableArray new];
    NSString *parsedRepresentation = representation;
    NSUInteger matchedParenCounter = 0;
    NSRange searchRange;
    NSCharacterSet *startSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
    NSCharacterSet *parenSet = [NSCharacterSet characterSetWithCharactersInString:@"(),"];
    
    do {
        NSRange startRange = [parsedRepresentation rangeOfCharacterFromSet:startSet];
        if (startRange.location != NSNotFound) {
            
            extractedKey = [parsedRepresentation substringToIndex:startRange.location];
//            if (extractedKey.length == startRange.location) { return nil; }
            parsedRepresentation = [parsedRepresentation substringFromIndex:startRange.location + 1];
            
            searchRange = NSMakeRange(0, parsedRepresentation.length);
            do {
                searchRange = [parsedRepresentation rangeOfCharacterFromSet:parenSet
                                                                    options:0
                                                                      range:searchRange];
                NSString *match = searchRange.location != NSNotFound ? [parsedRepresentation substringWithRange:searchRange] : nil;
                if (match == nil) { extractedValuePath = parsedRepresentation; break; }
                
                // '(' add 1, ')' subtracts 1, ',' does nothing
                matchedParenCounter = [match isEqualToString:@"("] ? matchedParenCounter + 1 : ([match isEqualToString:@")"] ? matchedParenCounter - 1 : matchedParenCounter);
                searchRange = NSMakeRange(searchRange.location + 1, parsedRepresentation.length - searchRange.location - 1);
            } while (matchedParenCounter != 0);
            
            extractedValuePath = extractedValuePath == nil ? [parsedRepresentation substringToIndex:searchRange.location] : extractedValuePath;
            [keyedValuePaths addObject:@{extractedKey:extractedValuePath}];

            if (searchRange.location < parsedRepresentation.length && [[parsedRepresentation substringWithRange:NSMakeRange(searchRange.location, 1)] isEqualToString:@","]) {
                searchRange = NSMakeRange(searchRange.location + 1, searchRange.length - 1);
            }
            parsedRepresentation = searchRange.location == parsedRepresentation.length ? nil : [[parsedRepresentation substringFromIndex:searchRange.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (parsedRepresentation.length == 0) { parsedRepresentation = nil; }

        }
    } while (parsedRepresentation != nil);
    
    return keyedValuePaths;
}

- (NSArray <NSDictionary *> *)valuePathsFromStringRepresentation:(NSString *)representation {
    NSString *extractedValuePath = nil;
    NSMutableArray *valuePaths = [NSMutableArray new];
    NSString *parsedRepresentation = representation;
    NSUInteger matchedParenCounter = 0;
    NSRange searchRange;
    NSCharacterSet *parenSet = [NSCharacterSet characterSetWithCharactersInString:@"(),"];
    
    do {
        searchRange = NSMakeRange(0, parsedRepresentation.length);
        do {
            searchRange = [parsedRepresentation rangeOfCharacterFromSet:parenSet
                                                                options:0
                                                                  range:searchRange];
            NSString *match = searchRange.location != NSNotFound ? [parsedRepresentation substringWithRange:searchRange] : nil;
            if (match == nil) { extractedValuePath = parsedRepresentation; break; }
            
            // '(' add 1, ')' subtracts 1, ',' does nothing
            matchedParenCounter = [match isEqualToString:@"("] ? matchedParenCounter + 1 : ([match isEqualToString:@")"] ? matchedParenCounter - 1 : matchedParenCounter);
            searchRange = NSMakeRange(searchRange.location + 1, parsedRepresentation.length - searchRange.location - 1);
        } while (matchedParenCounter != 0);
        
        extractedValuePath = extractedValuePath != nil ? [parsedRepresentation substringToIndex:searchRange.location] : extractedValuePath;
        [valuePaths addObject:extractedValuePath];
        
        if (searchRange.location < parsedRepresentation.length && [[parsedRepresentation substringWithRange:NSMakeRange(searchRange.location, 1)] isEqualToString:@","]) {
            searchRange = NSMakeRange(searchRange.location + 1, searchRange.length - 1);
        }
        parsedRepresentation = searchRange.location == parsedRepresentation.length ? nil : [[parsedRepresentation substringFromIndex:searchRange.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (parsedRepresentation.length == 0) { parsedRepresentation = nil; }
        
    } while (parsedRepresentation != nil);
    
    return valuePaths;
}

////////////////////////////////////////////////////////////////////////
///////////////////////// VALUE OPERATORS /////////////////////////
////////////////////////////////////////////////////////////////////////


- (id)composeUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSString *targetObject = [format stringWithSubstitutionsVariables:self];
    return keyPath == nil ? targetObject : [targetObject valueForKeyPath:keyPath];
}

- (id)filterUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    id targetObject = [predicate evaluateWithObject:self] ? self : nil;
    return keyPath == nil ? targetObject : [targetObject valueForExtendedKeyPath:keyPath];
}


/**
 Combine assembles a new object using a specified class and using values returned by a set of key/keypath operators. For example, to create a new dictionary object, the format string would be:
 
 "NSMutableDictionary, key:keypath, key:keypath, key:kepPath"

 Note that the properties of the instance must be settable. Therefore, creating a dictionary is not possible using combine. However, once the mutable dictionary has been created, a transformer can be applied that will convert the mutable dictionary into a immutable dictionary.
 
 @param format contains a comma separated list including:
 * Class to create
 * List of colon separated key-value pairs where key is the name of the property in the new object that should take the value resulting from the application of the keypath to the input object.
 @param keyPath A keyPath that will be applied to the resulting object.
 @return The newly created object or nil.
 */
- (id)combineUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSString *parsedString = [format stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange classRange = [parsedString rangeOfString:@","];
    id targetObject = [NSClassFromString([parsedString substringToIndex:classRange.location]) new];
    parsedString = parsedString.length > classRange.location ? [[parsedString substringFromIndex:classRange.location + 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : nil;
    if (parsedString == nil || targetObject == nil) { return targetObject; }
    
    for (NSDictionary *keyedValuePath in [self keyedValuePathsFromStringRepresentation:parsedString]) {
        id value = [self valueForExtendedKeyPath:keyedValuePath.allValues.firstObject];
        [targetObject setValue:value forKey:keyedValuePath.allKeys.firstObject];
    }
    
    return targetObject;
}

- (id)indexUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    id targetObject = self;
    if (([self respondsToSelector:@selector(objectAtIndex:)] == YES) &&
        ([format respondsToSelector:@selector(integerValue)])) {
        targetObject = [targetObject objectAtIndex:[format integerValue]];
    } else { targetObject = nil; }
    return keyPath == nil ? targetObject : [targetObject valueForExtendedKeyPath:keyPath];

}


- (id)transformUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:format];
    id targetObject = transformer != nil ? [transformer transformedValue:self] : nil;
    return keyPath == nil ? targetObject : [targetObject valueForExtendedKeyPath:keyPath];

}


- (id)expressUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSExpression *expression = [NSExpression expressionWithFormat:format, nil];
    id targetObject = expression != nil ? [expression expressionValueWithObject:self
                                                                        context:nil] : nil;
    return keyPath == nil ? targetObject : [targetObject valueForExtendedKeyPath:keyPath];
    
}

- (id)exitUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    return  [predicate evaluateWithObject:self] ? self : [self valueForExtendedKeyPath:keyPath];
}

////////////////////////////////////////////////////////////////////////
///////////////////////// COLLECTION OPERATORS /////////////////////////
////////////////////////////////////////////////////////////////////////

/**
 Applies the format expression to each element within a collection, returning each result within a collection of non-nil objects. If all objects within the collection evaluate to nil, returns an empty collection of the input type.

 @param format A keyPath to apply to each element in the collection
 @param keyPath A keyPath that will be applied to the resulting collection.
 @return The value resulting from the application of format to each element of the collection.
 */
- (id)mapUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    
    BOOL isKeyedValue = NO, isCollection = NO;
    id newCollection = nil;

    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        isCollection = YES;
        if ([self isKindOfClass:[NSDictionary class]]) {
            newCollection = [NSMutableDictionary new];
            isKeyedValue = YES;
        } else if ([self isKindOfClass:[NSArray class]]) {
            newCollection = [NSMutableArray new];
        } else if ([self isKindOfClass:[NSSet class]]) {
            newCollection = [self isKindOfClass:[NSOrderedSet class]] ? [NSOrderedSet new] : [NSMutableSet new];
        }
    }
    
    if (isCollection) {
        for (id object in self) {
            id targetObject = isKeyedValue ? @{object:((NSDictionary *)self)[object]} : object;
            targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;
            if (isKeyedValue && targetObject != nil) {
                [newCollection setObject:targetObject forKey:object];
            } else if (targetObject != nil) {
                [newCollection addObject:targetObject];
            }
        }
    } else {
        id targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;
        newCollection = targetObject != nil ? @[targetObject] : @[];
        
    }
    return keyPath == nil ? newCollection : [newCollection valueForExtendedKeyPath:keyPath];
}


/**
 Produces a result by providing the prior result to the subsequent calculation.
 
 A folding calculation enables a collection of objects, often numerical values, to be operated on sequentially with each prior operation effecting the outcome of the subsequent operation.
 
 When constructing the expression format, the following are made available:
 * Evaluated Object as SELF. If the input collection is a dictionary, this will be a single value dictionary.
 * Prior Calculated values as $OUTPUT. Note that on the initial pass, $OUTPUT will be an NSNull instance.
 * Collection being operated on as $INPUT.
 * Current execution pass as $COUNT.

 @param format An NSExpression format string that may reference a substitution dictionary and the current element of the collection.
 @param keyPath A keyPath that will be applied to the resulting NSNumber object.
 @return A single object value of any objective-C type.
 */
- (id)foldUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    
    BOOL isKeyedValue = NO, isCollection = NO;
    id outputObject = [NSNull null];
    NSUInteger count = 0;
    
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        isCollection = YES;
        if ([self isKindOfClass:[NSDictionary class]]) {
            isKeyedValue = YES;
        }
    }
    
    if (isCollection) {
        for (id object in self) {
            id targetObject = isKeyedValue ? @{object:((NSDictionary *)self)[object]} : object;
            targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;

            NSMutableDictionary *context = [NSMutableDictionary new];
            [context setObject:self forKey:@"INPUT"];
            [context setObject:outputObject forKey:@"OUTPUT"];
            [context setObject:@(count) forKey:@"COUNT"];
            NSExpression *targetExpression = [NSExpression expressionWithFormat:format];
            targetObject = [targetExpression expressionValueWithObject:targetObject
                                                               context:context];
            outputObject = targetObject != nil ? targetObject : outputObject;
            count++;
        }
    } else {
        id targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;
        NSMutableDictionary *context = [NSMutableDictionary new];
        [context setObject:self forKey:@"INPUT"];
        [context setObject:[NSNull null] forKey:@"OUTPUT"];
        [context setObject:@(count) forKey:@"COUNT"];
        NSExpression *targetExpression = [NSExpression expressionWithFormat:format];
        targetObject = [targetExpression expressionValueWithObject:targetObject
                                                                 context:context];
        outputObject = targetObject != nil ? targetObject : outputObject;
        
    }
    
    outputObject = [outputObject isEqual:[NSNull null]] ? nil : outputObject;
    
    return keyPath == nil ? outputObject : [outputObject valueForKeyPath:keyPath];

}


- (id)collectUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    
    NSString *parsedString = format != nil ? [format stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : nil;
    if (parsedString == nil || parsedString.length == 0) { return nil; }
    
    NSRange classRange = [parsedString rangeOfString:@","];
    NSString *className = classRange.location == NSNotFound ? parsedString : [parsedString substringToIndex:classRange.location];
    id targetObject = [NSClassFromString(className) new];
    parsedString = parsedString.length < classRange.location ? [[parsedString substringFromIndex:classRange.location + 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : nil;
    if (parsedString == nil || parsedString.length == 0 || targetObject == nil) { return targetObject; }
    
    for (id valuePath in [self valuePathsFromStringRepresentation:parsedString]) {
        id value = [self valueForExtendedKeyPath:valuePath];
        if (value == nil) { continue; }
        [targetObject addObject:value];
    }
    
    return targetObject;
}

- (id)flattenUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    id targetObject = nil;
    NSString *parsedString = format != nil ? [format stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : nil;
    
    if (parsedString == nil || parsedString.length == 0) {
        targetObject = [NSMutableArray new];
        
    } else {
        NSRange classRange = [parsedString rangeOfString:@","];
        NSString *className = classRange.location == NSNotFound ? parsedString : [parsedString substringToIndex:classRange.location];
        targetObject = [NSClassFromString(className) new];
        parsedString = parsedString.length < classRange.location ? [[parsedString substringFromIndex:classRange.location + 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : nil;

        if (targetObject == nil ||
            [targetObject respondsToSelector:@selector(addObject:)] == NO) {
            return nil;
        }
    }
    
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)] == NO) {
        [targetObject addObject:self];
        return targetObject;
    }
    
    NSArray *valuePaths = [self valuePathsFromStringRepresentation:parsedString];
    NSString *testPath = valuePaths.firstObject;
    NSUInteger maxDepth = valuePaths.count > 1 &&
    [valuePaths[1] respondsToSelector:@selector(integerValue)] == YES ? [valuePaths[1] integerValue] : 2;

    return [self collection:targetObject withElementsPassingTest:testPath maxDepth:maxDepth];

}

- (id)collection:(id)mutableCollection withElementsPassingTest:(NSString *)keyPath maxDepth:(NSUInteger)depth {
    
    for (id object in self) {
        if ([object respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)] == YES &&
            depth > 0) {
            [object collection:mutableCollection withElementsPassingTest:keyPath maxDepth:depth - 1];
        } else {
            id testObject = [object valueForExtendedKeyPath:keyPath];
            if (testObject != nil) { [mutableCollection addObject:testObject]; }
        }
    }
    
    return mutableCollection;
}

/**
 Calculates the average of numerical values within a collection.

 @param format The keyPath to the numerical values that should be used in the calculation.
 @param keyPath A keyPath that will be applied to the resulting NSNumber object.
 @return An NSNumber representing the average of the numerical values retrieved from the collection. If the input is not a collection, returns the numerical value of the input. If any value of the collection does not respond to doubleValue, it is treated as 0.
 */
- (id)avgUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    BOOL isKeyedValue = NO, isCollection = NO;
    double sum = 0, divisor = 0;

    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        isCollection = YES;
        if ([self isKindOfClass:[NSDictionary class]]) {
            isKeyedValue = YES;
        }
    }
    
    if (isCollection) {
        for (id object in self) {
            id targetObject = isKeyedValue ? @{object:((NSDictionary *)self)[object]} : object;
            targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;
            sum = targetObject != nil && [targetObject respondsToSelector:@selector(doubleValue)] ? sum + [targetObject doubleValue] : sum;
            divisor++;
        }
    } else {
        id targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;
        sum = targetObject != nil ? sum + [targetObject doubleValue] : sum;
        divisor++;
    }
    
    return keyPath == nil ? @(sum / divisor) : [@(sum / divisor) valueForKeyPath:keyPath];
}

/**
 Calculates the sum of numerical values within a collection.
 
 @param format The keyPath to the numerical values that should be used in the calculation.
 @param keyPath A keyPath that will be applied to the resulting NSNumber object.
 @return An NSNumber representing the sum of the numerical values retrieved from the collection. If the input is not a collection, returns the numerical value of the input. If any value of the collection does not respond to doubleValue, it is treated as 0.
 */
- (id)sumUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    BOOL isKeyedValue = NO, isCollection = NO;
    double sum = 0;
    
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        isCollection = YES;
        if ([self isKindOfClass:[NSDictionary class]]) {
            isKeyedValue = YES;
        }
    }
    
    if (isCollection) {
        for (id object in self) {
            id targetObject = isKeyedValue ? @{object:((NSDictionary *)self)[object]} : object;
            targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;
            sum = targetObject != nil && [targetObject respondsToSelector:@selector(doubleValue)] ? sum + [targetObject doubleValue] : sum;
        }
    } else {
        id targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;
        sum = targetObject != nil ? sum + [targetObject doubleValue] : sum;
    }
    
    return keyPath == nil ? @(sum) : [@(sum) valueForKeyPath:keyPath];
}

/**
 Returns the number of values at a keypath.
 
 @param format The keyPath to the values that should be used in the calculation.
 @param keyPath A keyPath that will be applied to the resulting NSNumber object.
 @return An NSNumber representing the count of the values retrieved from the collection. If the input is not a collection, returns one for a non-nil result.
 */
- (id)countUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    BOOL isKeyedValue = NO, isCollection = NO;
    double count = 0;
    
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        isCollection = YES;
        if ([self isKindOfClass:[NSDictionary class]]) {
            isKeyedValue = YES;
        }
    }
    
    if (isCollection) {
        for (id object in self) {
            id targetObject = isKeyedValue ? @{object:((NSDictionary *)self)[object]} : object;
            targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;
            if (targetObject != nil) { count++; }
        }
    } else {
        id targetObject = format != nil ? [self valueForExtendedKeyPath:format] : self;
        if (targetObject != nil) { count++; }
    }
    
    return keyPath == nil ? @(count) : [@(count) valueForKeyPath:keyPath];
}

/**
 Returns the minimum of value at a keypath.
 
 @param format The keyPath to the values that should be used in the calculation.
 @param keyPath A keyPath that will be applied to the resulting NSNumber object.
 @return The minimum value retrieved from the collection based on using the compare: method. If the input is not a collection, returns the object if it responds to compare:. Returns nil if the value can not be compared.
 */
- (id)minUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    BOOL isKeyedValue = NO, isCollection = NO;
    id minimum = nil;

    
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        isCollection = YES;
        if ([self isKindOfClass:[NSDictionary class]]) {
            isKeyedValue = YES;
        }
    }
    
    if (isCollection) {
        for (id object in self) {
            id targetObject = isKeyedValue ? @{object:((NSDictionary *)self)[object]} : object;
            targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;
            if (minimum == nil && targetObject != nil && [targetObject respondsToSelector:@selector(compare:)]) {
                minimum = targetObject;
                continue;
            }
            minimum = targetObject != nil && [targetObject respondsToSelector:@selector(compare:)] && ([minimum compare: targetObject] == NSOrderedAscending) ? minimum: targetObject;
        }
        
    } else {
        id targetObject = format != nil ? [self valueForExtendedKeyPath:format] : self;
        minimum = [targetObject respondsToSelector:@selector(compare:)] ? targetObject : nil;
    }
    
    return keyPath == nil ? minimum : [minimum valueForKeyPath:keyPath];
}

/**
 Returns the maximum of value at a keypath.
 
 @param format The keyPath to the values that should be used in the calculation.
 @param keyPath A keyPath that will be applied to the resulting NSNumber object.
 @return The maximum value retrieved from the collection based on using the compare: method. If the input is not a collection, returns the object if it responds to compare:. Returns nil if the value can not be compared.
 */
- (id)maxUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    BOOL isKeyedValue = NO, isCollection = NO;
    id maximum = nil;
    
    
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        isCollection = YES;
        if ([self isKindOfClass:[NSDictionary class]]) {
            isKeyedValue = YES;
        }
    }
    
    if (isCollection) {
        for (id object in self) {
            id targetObject = isKeyedValue ? @{object:((NSDictionary *)self)[object]} : object;
            targetObject = format != nil ? [targetObject valueForExtendedKeyPath:format] : targetObject;
            if (maximum == nil && targetObject != nil && [targetObject respondsToSelector:@selector(compare:)]) {
                maximum = targetObject;
                continue;
            }
            maximum = targetObject != nil && [targetObject respondsToSelector:@selector(compare:)] && ([maximum compare: targetObject] == NSOrderedDescending) ? maximum: targetObject;
        }
        
    } else {
        id targetObject = format != nil ? [self valueForExtendedKeyPath:format] : self;
        maximum = [targetObject respondsToSelector:@selector(compare:)] ? targetObject : nil;
    }
    
    return keyPath == nil ? maximum : [maximum valueForKeyPath:keyPath];
}



@end

