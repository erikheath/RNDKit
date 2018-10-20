//
//  RNDValuePathExtensions.h
//  RNDKit
//
//  Created by Erikheath Thomas on 5/23/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 
 @category NSObject(RNDValuePathExtensions)
 
 @discussion The value path extensions are designed to enable routine processing tasks to be encoded in a compact form suitable for use in user interfaces and other dynamic environments. An example of that type of environment is in the processing of JSON, XML, or other text-to-object based data where data may or may not be present and/or where data must be searched for to determine its presence. Cocoa's Key Value Coding mechanism enables traversal, but in general is not designed to accomodate missing data, and often results in exceptions when processing.
 
 Value path extensions provide a parallel and functionally similar feature set with extensions to accomodate common processing, error handling, and exception prevention. This means that instead of working on the logic of processing text-to-object based data, the processing can be expressed at a higher level which generally results in less opportunity for undetected bugs.
 
 For example, to construct an object from a JSON data source is a two step process.
 
 1. Deserialize the data using NSJSON... based methods.
 
 2. Take the resulting JSON based object graph (the output of the deserializer) and apply the \@construct() operator to it with a set of key/key path pairs to retrieve the data that should be set on the object to be constructed.
 
 To write data back to a JSON data source take the existing JSON based object graph (the output of the deserializer with a mutable leaves option) and apply the \@assign() operator to it with a set of key/key path pairs and/or index/key path pairs to set the data in the graph.
 
 To remove data from the JSON data source, take the existing JSON based object graph (the output of the deserializer with a mutable leaves option) and apply the \@remove() operator to it with a set of keys and/or indices to remove data in the graph.
 
 When combined with \@bind(), \@forward(), and \@reverse() operators, a deserialized JSON object graph can be used as a read-only or read-write data source for a UI with little to no custom controller code, making it possible to associate controller behavior with the UI it controls in Interface Builder.
 
 Error and Exception handling is consistent throughout the value path extensions, but differs from typical Cocoa reference based semantics. If an error occurs that genrates an NSError object, that error is provided as the output of the operator. This means that, without intervention, processing can continue with the error object as the next input object.
 
 While most processing will only generate an error, there are cases where processing may generate an exception. In those cases, the exception is automatically wrapped in an error object, and provided as the next input object.
 
 If an error occurs, the general strategy is as follows:
 
 1. At any point where an error should result in termination, use the \@error() operator to test for the presence of an error.
 
 2. If the input object is a matching error, the \@error() operator will return nil. Otherwise the input object will be passed to the next operator.
 
 For more complex error handling multiple \@error() operators can be chained together to match specific errors while allowing other ones to be handled by other operators. For greater control, the @processor() directive can be used to invoke a custom RNDProcessor object to handle an error.
 
 */
@interface NSObject(RNDValuePathExtensions)

- (nullable id)valueForExtendedKeyPath:(NSString *)keyPath;

@end
