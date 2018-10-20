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


//  TODO: Add debug logging when errors occur, optional runtime logging when errors occur.
//  TODO: Add String and Number literals for value path parsing
//  TODO: COUNTBY... DOES NOT INDICATE KEYED COLLECTION
//  TODO: Add documentation for each method
//  TODO: Fix valuePathsFrom... method to generate array of strings
//  TODO: At some point, support numbers in other formats
//  TODO: Remove quotes that indicate string in @compose()


@implementation NSObject(RNDValuePathExtensions)

/*!
 @method valueForExtendedKeyPath:
 
 @abstract Parses a key path for dot separators '.', operator symbols '@', and operator inputs enclosed in parentheses '(' and ')'.
 
 @param keyPath A key path that will be applied to object.
 
 @result The result of the application of the key path to object. May be nil.

 */
- (nullable id)valueForExtendedKeyPath:(NSString *)keyPath {

    NSString *extractedKey = nil;
    NSString *nextKeyPath = nil;

    NSUInteger matchedParenCounter = 0;
    NSRange searchRange;
    NSCharacterSet *startSet = [NSCharacterSet characterSetWithCharactersInString:@".@"];
    NSCharacterSet *parenSet = [NSCharacterSet characterSetWithCharactersInString:@"()"];
    
    // BEGIN: Extracts the leftmost key from the key path.
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
    // END: Extracts the leftmost key from the key path.
    
    id input = self;
    
    if ([extractedKey hasPrefix:@"@"] == NO) {
        id nextInput = [input valueForKey:extractedKey];
        return nextKeyPath != nil ? [nextInput valueForExtendedKeyPath:nextKeyPath] : nextInput;
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
#pragma mark - Utilities


- (NSArray <NSDictionary <NSString *, NSString *> *> *)keyedValuePathsFromStringRepresentation:(NSString *)representation {
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


/**
 Returns an array of value paths.
 **/
- (NSArray <NSString *> *)valuePathsFromStringRepresentation:(NSString *)representation {
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

////////////////////////////////////////////////////////////////////////
///////////////////////// VALUE OPERATORS /////////////////////////
////////////////////////////////////////////////////////////////////////
#pragma mark - Value Operators


/**
 \@assign() sets one or more values on an object or adds/replaces one or more values on a keyed collection. The format string must contain zero or more colon separated key / key path pairs. The key corresponds to a property name of an input object or to a key format compatible name for adhoc value entries (such as in a dictionary) if the object provides that functionality.
 
 @param format One or more key:key path pairs that evaluate to values to assign to the input object.
 
 @param keyPath A keyPath that will be applied to the resulting object.
 
 @result The input value updated with any additions resulting from the evaluation of the format string key paths.
 
 **/
- (id)assignUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    id targetObject = self;
    for (NSDictionary * valuePathKeyPair in [self keyedValuePathsFromStringRepresentation:keyPath]) {
        NSString *valuePathKey = [[valuePathKeyPair allKeys] firstObject];
        id value = [self valueForExtendedKeyPath:valuePathKeyPair[valuePathKey]];
        if (value == nil) { value = [NSNull null]; }
        [self setValue:value forKey:valuePathKey];
    }
    
    return targetObject;
}


/**
 The \@bind() operator enables synchronization of an observer and observed object by creating a value path pipeline between them using the RNDKit binding system. In an \@bind() statement, the input object is the observer and the observed object is specified in the format string by a binding name. In addition, the key of the observing object that should be synchronized
 
 For example, to bind a UITextField's text property to an NSMutableDictionary with a value named accountBalance:
 
 @textblock
 
 [myTextField setValue:@"@bind(observedName, accountBalance:@format(RNDNumberCurrency), reversible:YES, nullPlaceholder:@compose(\"Unknown Value\"), inProgressPlaceholder:@compose(\"Refresh in Progress\"))"
              forKey:@"@bind(text)"];
 
 @/textblock
 
 In this example, the setValue creates a processing pipeline that:
 
 1. Defines the name of the observed object followed by the key of the object that will be observed. The name of the observed object is treated as a key path when processed and therefore supports traversal through an object graph using value path operators.
 
 2. Formats the value if a null or placeholder marker is not received.
 
 3. If a null is received, the value is replaced by the nullPlaceholder.
 
 4. If an inProgressPlaceholder is received, the value is replaced by the inProgressPlaceholder.
 
 The forKey: bind statement provides the name of property on the observing object that will be synchronized.
 
 When using the \@bind() operator, the operator must be the terminating top-level operator in the statement. No subsequent operator is valid.
 
 @note When binding objects in Interface Builder, the syntax of the binding is identical to  setValue:forKey in the example above. Because the bind statements are evaluated after the standard Interface Builder configurations have occurred, you can set any of the properties of an object in the standard panels. However, if you set custom values using IBInspectable for a property you intend to bind and do not want those values to write to your data source, include the keepInitialValue property in the setValue: bind statement and declare its value as NO. This will block the synchronization of values set by the NIB to the data source.
 
 To ensure that the objects are synchronized, set syncOnAwake in the setValue: bind statement to YES. This will ensure that each bound item reflects the current state of the data source once it has been initialized configured by the NIB loading system.
 
 Taking the previous example, to bind a UITextField named myTextField to a controller named myController that has an NSMutableDictionary property named myData acting as a data source, you could add the following to the runtime variables list in Interface Builder.
 
 @textblock
 Key            Value
 @bind(text)    @bind(myController.myData, accountBalance:@format(RNDNumberCurrency),
                reversible:YES, nullPlaceholder:@compose(\"Unknown Value\"),
                inProgressPlaceholder:@compose(\"Refresh in Progress\"),
                keepInitialValue:NO, syncOnAwake:YES)
 
 @/textblock
 
 @seealso For a complete discussion of binding in RNDKit, see the RNDKit Binding Topics.
 
 @param format For setValue: statements, the format string contains the name of the observed object in key path form,
 
 @param keyPath A key path that will be applied to the resulting object.
 
 @return The newly created object or nil.
 */
- (id)bindUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    return  [predicate evaluateWithObject:self] ? self : [self valueForExtendedKeyPath:keyPath];
}


/**
 @abstract \@compose() produces a new string object using a template string with zero or more placeholders. \@compose() treats the input object as a dictionary where keys of the input object must map to the template placeholders in the string for replacement to occur. The value associated with a key / template placeholder will be substituted into the template string.
 
 @discussion For example, the following format string has two template placeholders:
 
 "This $placeholderA string with two $placeholderB placeholders."
 
 The first variable is $placeholderA and the second is $placeholderB. If $placeholderA == "is a" and $placeholderB == "template" then the resulting string would be:
 
 "This is a string with two template placeholders."
 
 While a delimiter is not necessary to map substitutions into the format string, they are useful to prevent unwanted substitutions from occurring during string processing. Note that the string is processed once for every substitution variable in the input object. The order of processing is not determined until runtime and may vary between invocations, therefore the use of a delimiter which makes the template placeholder unique is preferred.
 
 \@compose can also be used to create string literals from a template string with zero placeholders, a template string from a key path that evaluates to a string, and a number literal that will be converted to an NSNumber object. Because of this, @compose is useful in many of the other operator format strings to dynamically create values.

 @param template contains a format string with zero or more substitution variables, a key path, or a number literal.
 
 @param keyPath A key path that will be applied to the resulting object.
 
 @return The newly created object or nil.
 */
- (id)composeUsingFormat:(NSString *)template subsequentKeyPath:(NSString *)keyPath {
    NSString *processedTemplate = [template stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableCharacterSet *variableNameSet = [NSMutableCharacterSet letterCharacterSet];
    [variableNameSet addCharactersInString:@"_"];
    id targetObject = nil;
    
    if ([processedTemplate hasPrefix:@"\""] == YES && [processedTemplate hasSuffix:@"\""] == YES) {
        // This is a string literal.
        processedTemplate = [processedTemplate substringWithRange:NSMakeRange(1, processedTemplate.length - 2)];
        targetObject = [processedTemplate stringWithSubstitutions:self];
    } else if ([processedTemplate rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != 0) {
        // This is a number literal.
        targetObject = [processedTemplate rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"."]].location == NSNotFound ? [NSNumber numberWithInteger:[processedTemplate integerValue]] : [NSNumber numberWithDouble:[processedTemplate doubleValue]];
    } else if ([processedTemplate rangeOfCharacterFromSet:variableNameSet].location != 0) {
        // This is a key path that must be evaluated.
        targetObject = [self valueForExtendedKeyPath:processedTemplate];
    } else {
        // This is not a compatible.
        // TODO: Error handling / logging
        // TODO: It's possible for a string to start with a quote but not end with one.
    }
    
    return keyPath == nil ? targetObject : [targetObject valueForKeyPath:keyPath];
}


/**
 @construct() assembles a new object using a specified class and keyed values returned by a set of key/key path pairs where the key corresponds to the property to be set in the new object and the key path corresponds to the new object's property value. The key path generates a value by being applied to the input object. The string it expects has the following format:
 
 className, keyA:keyPathA, keyB:keyPathB, keyC:keyPathC, etc.
 
 In addition to a key path, @construct() will also accept constant strings in single quotes, and it will autobox (convert to NSNumber) any string value beginning with a number.
 
 For example, to create a new NSURLComponents object from an input object named keyedStringsObject that contains keyed strings (i.e. a dictionary of strings), you could use the following:
 
 keyedStringsObject.@construct(NSURLComponents, host: hostString, scheme: 'https', path: pathString)
 
 In this example, an NSURLComponents object is created with its host set to the value returned by hostString, its scheme set to the string constant 'https', and its path set to the value returned by pathString.
 
 @construct() can set any value on an object where that object responds to setValue:forKey for a given key. For example, a mutable dictionary can be created as follows.
 
 @construct(NSMutableDictionary, key1: 4.0, key2: 3.0, key3: 'key3Value')
 
 Note that because the properties to be set on an instance must be settable, creating an immutable dictionary is not possible using @construct(). However, once a mutable dictionary has been created, a transformer can be applied that will convert the mutable dictionary into an immutable dictionary. In addition, @construct() requires a class to have a standard no-parameter initializer. For classes that require parameters within an initializer, use the @express() operator.
 
 @param format contains a comma separated list including:
 * Class to create
 * List of colon separated key-value pairs where key is the name of the property in the new object that should take the value resulting from the application of the key path to the input object.
 @param keyPath A key path that will be applied to the resulting object.
 @return The newly created object or nil.
 */
- (id)constructUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
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


- (id)errorUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
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


/**
 @exit() evaluates the input object to determine if processing should continue. @exit() uses a predicate created from the format string to test the input object. If the test returns true, subsequent processing is terminated by returning the input object as the result. If the test returns false, processing continues past the @exit operator.
 
 @param format a string that can be converted to a NSPredicate object.
 
 @param keyPath A key path that will be applied to the resulting object.
 
 @return The newly created object or nil.
 */
- (id)exitUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    return  [predicate evaluateWithObject:self] ? self : [self valueForExtendedKeyPath:keyPath];
}



/**
 @express() creates an expression object from the format string and returns the result of applying it to the input object.
 
 @param format a string that can be converted to a NSExpression object.
 
 @param keyPath A key path that will be applied to the resulting object.
 
 @return The newly created object or nil.
 */
- (id)expressUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSExpression *expression = [NSExpression expressionWithFormat:format, nil];
    id targetObject = expression != nil ? [expression expressionValueWithObject:self
                                                                        context:nil] : nil;
    return keyPath == nil ? targetObject : [targetObject valueForExtendedKeyPath:keyPath];
    
}



/**
 @filter() constructs a predicate from the format string and applies the resulting predicate to the input object (sometimes termed the predicate's evaluated object). The format string supports the full breadth of predicate string components which are described in the predicate programming guide. The input object is used to substitute any variables in the resulting predicate. Therefore, SELF in a predicate string will refer to the input object, and referring to any keyed values contained in the input object can be accomplished using a standard (non-extended) key path.
 
 Note that predicates can not be formed using any extended key path operator, however, in circumstances where an extended key path operator is needed, it can be accessed using NSExpression's FUNCTION operator.
 
 @param format contains a NSPredicate compliant format string.
 
 @param keyPath A key path that will be applied to the resulting object.
 
 @return The newly created object or nil.
 */
- (id)filterUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    id targetObject = [predicate evaluateWithObject:self] ? self : nil;
    return keyPath == nil ? targetObject : [targetObject valueForExtendedKeyPath:keyPath];
}


/**
 @index() accesses a value at a specified index location. Typically used with arrays, this operator works with any object that responds to the objectAtIndex: method.
 
 @param format evaluates to a value that can be converted to an integer via the integerValue method.
 
 @param keyPath A key path that will be applied to the resulting object.
 
 @return The newly created object or nil.
 */
- (id)indexUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    id targetObject = self;
    if (([self respondsToSelector:@selector(objectAtIndex:)] == YES) &&
        ([format respondsToSelector:@selector(integerValue)])) {
        targetObject = [targetObject objectAtIndex:[format integerValue]];
    } else { targetObject = nil; }
    return keyPath == nil ? targetObject : [targetObject valueForExtendedKeyPath:keyPath];

}


/**
 @process()
 
 @param format
 
 @param keyPath A key path that will be applied to the resulting object.
 
 @return The newly created object or nil.
 */
- (id)processUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    return  [predicate evaluateWithObject:self] ? self : [self valueForExtendedKeyPath:keyPath];
}


/**
 @transform() applies a named value transformer to the input object, the result of which is returned.
 
 @param format the name of an existing value transformer.
 
 @param keyPath A key path that will be applied to the resulting object.
 
 @return The newly created object or nil.
 */
- (id)transformUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName:format];
    id targetObject = transformer != nil ? [transformer transformedValue:self] : nil;
    return keyPath == nil ? targetObject : [targetObject valueForExtendedKeyPath:keyPath];

}





////////////////////////////////////////////////////////////////////////
///////////////////////// COLLECTION OPERATORS /////////////////////////
////////////////////////////////////////////////////////////////////////
#pragma mark - Collection Operators


/**
 Applies the format expression to each element within a collection, returning each result in a new collection of non-nil objects. If any object within the collection evaluates to nil, the value is converted to an NSNull value. This operator will never result in a nil value. Passing a non-collection object will still result in application of the mapping key path to the input value, with the result wrapped in a single value array.

 @param format A key  path to apply to each element in the collection
 @param keyPath A key path that will be applied to the resulting collection.
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
            newCollection = [self isKindOfClass:[NSOrderedSet class]] ? [NSMutableOrderedSet new] : [NSMutableSet new];
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
            } else {
                [newCollection addObject:[NSNull null]];
            }
        }
    } else {
        id targetObject = format != nil ? [self valueForExtendedKeyPath:format] : self;
        newCollection = targetObject != nil ? @[targetObject] : @[[NSNull null]];
        
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
 
 If any object within the collection evaluates to nil, the value is converted to an NSNull value. This operator will never result in a nil value. A consequence of this is that a subsequent key path may operate on an NSNull instance. If that is a possibility with the input data, a @filter() or @exit() operator can be used to exclude or stop futher processing.

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
    
    return keyPath == nil ? outputObject : [outputObject valueForKeyPath:keyPath];

}

/**
 @remove() removes one or more values from a collection by key or index.
 **/
- (id)removeUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    BOOL isKeyedValue = [self respondsToSelector:@selector(setObject:forKey:)];
    id targetObject = self;
    
    for (id valuePath in [self valuePathsFromStringRepresentation:keyPath]) {
        if (isKeyedValue == YES) {
            [targetObject removeObjectForKey:valuePath];
        } else {
            NSUInteger index = [valuePath integerValue];
            [targetObject removeObjectAtIndex:index];
        }
    }
    return targetObject;
}

/**
 @collect() adds one or more values to an unkeyed collection.
 
 @param format One or more key paths that evaluate to values to add to the input collection.
 @param keyPath A keyPath that will be applied to the resulting collection.
 @return The input value updated with any additions resulting from the evaluation of the format string key paths.
 */
- (id)collectUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    id targetObject = self;
    for (id valuePath in [self valuePathsFromStringRepresentation:keyPath]) {
        id value = [self valueForExtendedKeyPath:valuePath];
        if (value == nil) { value = [NSNull null]; }
        if ([self respondsToSelector:@selector(addObject:)] == YES) {
            [targetObject addObject:value];
        } else {
            targetObject = [NSNull null];
        }
    }
    
    return targetObject;
}

/**
 Converts arrays of arrays or dictionaries of dictionaries to a single collection by merging the elements of the collections into a single collection.
 **/
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
            ([targetObject respondsToSelector:@selector(addObject:)] == NO && [targetObject respondsToSelector:@selector(setObject:forKey:)] == NO)) {
            return nil;
        }
    }
    
    if ([self respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)] == NO) {
        [targetObject addObject:self];
        return targetObject;
    }
    
    NSArray *valuePaths = [self valuePathsFromStringRepresentation:parsedString];
    NSString *testPath = valuePaths.firstObject;
    
    // maxDepth prevents infinite recursion for collections that have circular references.
    NSUInteger maxDepth = valuePaths.count > 1 &&
    [valuePaths[1] respondsToSelector:@selector(integerValue)] == YES ? [valuePaths[1] integerValue] : 2;

    return [self collection:targetObject withElementsPassingTest:testPath maxDepth:maxDepth];

}


////////////////////////////////////////////////////////////////////////
///////////////////////// ARITHMETIC OPERATORS /////////////////////////
////////////////////////////////////////////////////////////////////////
#pragma mark - Arithmetic Operators

/**
 Calculates the average of numerical values within a collection.

 @param format The keyPath to the numerical values that should be used in the calculation.
 @param keyPath A keyPath that will be applied to the resulting NSNumber object.
 @return An NSNumber representing the average of the numerical values retrieved from the collection. If the input is not a collection, returns the numerical value of the input. If any value of the collection does not respond to doubleValue, it is treated as 0.
 */
- (id)avgUsingFormat:(NSString *)format subsequentKeyPath:(NSString *)keyPath {
    BOOL isKeyedValue = NO, isCollection = NO;
    double sum = 0, divisor = 0;

    if ([self respondsToSelector:@selector(setObject:forKey:)]) {
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

