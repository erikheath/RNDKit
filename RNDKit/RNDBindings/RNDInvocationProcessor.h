//
//  RNDInvocationProcessor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 11/4/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "RNDBindingProcessor.h"


/*!
 @class RNDInvocationProcessor
 
 @version
 1.0a
 
 @updated
 9-15-2017
 
 @abstract
 The RNDInvocationProcessor class enables the dynamic construction and optional evaluation of NSInvocation objects.
 
 @discussion
 In RNDKit, NSInvocation objects are used to dynamically construct executable messages that can be delivered as output of a processing graph, generate new values as input to the processing graph, and/or trigger other behavior in the application. While an NSInvocation is limited to sending Objective-C messages, those messages can correspond to methods that wrap functions, enabling almost complete access to the capabilities of an application at runtime.
 
 The RNDInvocationProcessor requires:
 
 <ul>
 
 <li>An observed object
 
 <li>A bindingSelectorString that corresponds to a method registered for the observed object's instance or class type.
 
 </ul>
 
 If the processor can not locate a method signature based on the observed object and binding selector string, the processor will not construct the invocation and will instead return nil or the nil value placeholder.
 
 Like other objects that can evaluate a raw processor value, the RNDInvocationProcessor's version of evaluation consists of invoking the constructed NSInvocation object and returning the result as the processor's bindingObjectValue. The processor is designed to intelligently unwrap message arguments according to a destination method's signature, and to wrap return values as needed so that they can be passed through a processing graph.
 
 Because the processor uses the method signature encoding to determine how to treat argument values, the types of values it can pass in a message are limited and described below.
 
 @classdesign
 Scalar and Floating Point Types:
 
 All scalar and floating point types must be wrapped in an NSNumber or NSValue that will yield a valid type according to the expected type specified in the method signature. The following scalar and floating point types are supported via the following encodings in a method signature:
 <ul>
 
 <li> A char encoded as c in a method signature.
 
 <li> A int encoded as i in a method signature
 
 <li> A short encoded as s in a method signature
 
 <li> A long encoded as l in a method signature
 
 <li> A long long encoded as q in a method signature
 
 <li> A unsigned char encoded as C in a method signature
 
 <li> A unsigned int encoded as I in a method signature
 
 <li> A unsigned short encoded as S in a method signature
 
 <li> A unsigned long encoded as L in a method signature
 
 <li> A unsigned long long encoded as Q in a method signature
 
 <li> A float encoded as f in a method signature
 
 <li> A double encoded as d in a method signature
 
 <li> A C++ bool or C99 _Bool encoded as B in a method signature
 
 </ul>
 
 Scalar and float point types are retrieved from the NSNumber/NSValue wrapping and then a pointer to the value is passed to the NSInvocation object, which copies the values.

 
 Structure Types:
 
 The processor supports a limited number of structures due to an inablity to reconstitute unknown structure types. Because of this, only structure types that have NSValue or NSNumber constructors are supported by the processor. Only the following structure types are supported:
 
 <ul>
 <li> NSRange
 
 <li> NSPoint (macOS)
 
 <li> NSSize (macOS)
 
 <li> NSRect (macOS)
 
 <li> CGPoint
 
 <li> CGVector
 
 <li> CGSize
 
 <li> CGRect
 
 <li> CGAffineTransform
 
 <li> UIEdgeInsets
 
 <li> UIOffset
 
 <li> CATransform3D
 
 <li> CMTime
 
 <li> CMTimeRange
 
 <li> CMTimeMapping
 
 <li> CLLocationCoordinate2D
 
 <li> MKCoordinateSpan
 
 <li> SCNVector3
 
 <li> SCNVector4
 
 <li> SCNMatrix4
 
 <li> NSDirectionalEdgeInsets
 
 <li> NSEdgeInsets (macOS)
 
 </ul>
 
 Structure types are retrieved from the NSValue wrapping and then a pointer to the value is passed to the NSInvocation object, which copies the value.

 
 Other supported types:
 
 The RNDInvocationProcessor supports pointer and Objective-C related types as listed below:

 <ul>
 
 <li> A void encoded as v in a method signature
 
 <li> A character string (char *) encoded as * in a method signature
 
 <li> An Objective-C object encoded as @ in a method signature
 
 <li> A class object encoded as # in a method signature
 
 <li> A method selector encoded as : in a method signature
 
 <li> A pointer encoded as ^ in a method signature

 </ul>
 
 @note
 No other types are currently supported.
 
 When working with a pointer, scalar, floating point, or other non Objective-C return type, the encoding of the return type is included in the resulting NSValue or NSNumber object. Because of this, you can determine the underlying type by calling the ObjCType method of the NSValue/NSNumber object. This is useful when the return type of an invocation will vary based on runtime conditions.
 
 You can use the ObjCType information in combination with class type and an instance's value in predicate tests to alter flows including rejecting or transforming returned values.
 
 @note
 The NSInvocation object constructed by the processor will retain its arguments including its target. If the invocation is invoked as part of constructing the binding object value, the invocation will be set to nil following its evaluation, thus releasing its arguments and target.
 
 @warning
 The RNDInvocationProcessor wraps its NSInvocation invoke call in a try/catch block and will report the error. While this should stop propagation of the exception, it should not be relied upon as a mechasnism for managing methods that throw exceptions.
 */
@interface RNDInvocationProcessor : RNDBindingProcessor

/**
 @abstract A string that will be converted to a selector.
 
 @discussion
 The binding selector string must correspond to a string that can be converted to a selector that corresponds to a method registered with the observed object evaluation value. Both instance and class methods are supported and are chosen based on whether the observed object evaluation value is an instance or class object.
 */
@property (strong, readwrite, nullable) NSString *bindingSelectorString;

@end
