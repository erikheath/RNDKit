//
//  RNDBindingProcessor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../RNDBindingConstants.h"
#import "../RNDBindingProtocols+Categories/NSObject+RNDObjectBinding.h"

/**
 @abstract The RNDValueType determines the value semantics of the processorValue property.
 
 @constant RawValueOutputType: The processorValue will not be evaluated into it's final form.
 
 @constant CalculatedValueOutputType: The processorValue will be evaluated, optionally using the observedObjectBindingValue to evaluate against.

 @discussion A processor's output type is used to indicate whether the selected and constructed processorValue should be evaluated to generate a final value for the processor. Typically, this processing involves the value of the observed object's property, but this is not a requirement, and is often not used.
 
 The difference between the two output types is illustrated by the RNDRegExNode which can output a regular expression as its processorValue, or can apply that regular expression and replacement template to the value of it's observed object's property. The RNDPredicateNode, RNDInvocationNode, and RNDExpression processor have similar behavior.

 */
typedef NS_ENUM(NSUInteger, RNDProcessorOutputType) {
    RNDRawValueOutputType,
    RNDCalculatedValueOutputType
};

typedef NS_ENUM(NSUInteger, RNDValueMode) {
    RNDValueOnlyMode,
    RNDKeyedValueMode,
    RNDOrderedKeyedValueMode
};

@class RNDBinder;
@class RNDPatternedStringProcessor;
@class RNDPredicateProcessor;


/**
 @class RNDBindingProcessor
 
 @version 1.0a
 
 @updated 9-12-2017

 @abstract The RNDBindingProcessor class is the base class for all processors in the RNDBindings system.

 @discussion The RNDBindingProcessor class provides foundational support for binding to a Key-Value Coding compliant object's properties. When used as an inflow value processor of a binder, an RNDBindingProcessor forms a read-only binding to an observed object, connecting to and optionally Key-Value Observing an object's property. When used as an outflow value processor of a binder, an RNDBindingProcessor forms a write-only binding, connecting to an observed object's property and updating it as directed by the RNDBinder.
 
 While subclasses can extend RNDBindingProcessor to provide enhanced processing capabilities, the base class provides significant functionality including:
 
 <ul>
 <li> A sync queue that synchronizes read/write access to the classes properties.
 
 <li> KVC-based reading/writing of an observed object's property with the ability to monitor the property for changes using Key-Value Observing (KVO).
 
 <li> The option to read-from/write-to an observed object on the main queue.
 
 <li> The option to set placeholders for specific values such as nils, NSNull instances, and controller markers.
 
 <li> The ability to transform a value.
 
 <li> A number of other options used by subclasses to create arbitrarily complex processing trees.
 </ul>
 
 Because of this and because of the requirements when subclassing (see below), it is often better to compose functionality by creating a processing tree of RNDBindingProcessors and/or its subclasses than creating a more specialized subclass.
 
 @remark All RNDBindingProcessor properties are fully synchronized, and any subclasses should use the syncQueue or coordinate with it when introducing new properties. The syncQueue is a concurrent queue supporting a multi-read/single-write access model. Internally, the class implements this behavior using a dispatch barrier for writes. All property access (including writes) are synchronous which ensures that any calls after a property is written to will reflect the new (or any subsequent) value.
 
 In addition, all RNDBindingProcessor properties are readonly when a class instance has been bound by calling either the bind or bind:error methods. This ensures that information necessary for unbinding and removing KVO from observered objects is not prematurely deleted before that process is completed. To enable this, both the bind/bind:error methods and the unbind/unbind:error methods execute the bindObjects:error and unbindObjects:error methods respectively on the synchQueue using an exclusion barrier that prevents other objects from reading/writing while the bindng/unbinding process takes place.
 
 @note When subclassing RNDBindingProcessor, it may be necessary to add functionality to the binding and unbinding process, for example to initialize properties added by the subclass or to perform additional checks relevant to the subclass. To accomplish this, subclasses should override the bindObjects and unbindObjects methods, calling the super class's implementation at the beginning of the method and exiting if the super class's binding operation is unsuccessful. In addition, if the subclass's custom binding process is not successful, the subclass should call the super class's unbindObjects implementation to return the instance to an unbound state. It is also good practice to call the subclasses implementation of unbindObjects to clean up any changed state. Doing this should return the object to a pristine state ready to attempt binding again. By overriding the bindObjects:error and unbindObjects:error methods, you will not need to override the bind/bind:error methods and the unbind/unbind:error methods as they are used as the public interface to call the bindObjects and unbindObjects methods on the syncQueue.
 
 
 */
@interface RNDBindingProcessor : NSObject <NSCoding>

/**
 @abstract The synchronization queue used to coordinate reads/writes for instance properties.
 
 @discussion The syncQueue coordinates reading and writing to properties, including preventing property mutation when an instance is binding or unbinding from an observed object. The syncQueue is automatically created for an RNDBindingProcessor instance and has a unique application-wide runtime identifier.
 */
@property (nonnull, strong, readonly) dispatch_queue_t syncQueue;

/**
 @abstract The binder the processor is managed by.
 
 @discussion Nodes use a binder to gain access to the larger object graph. This includes automatic configuration of a processor's observed object, notifying the binder that a change has been detected and an update may be required, informing the binder about the status of a binding attempt, and producing values that a binder can use for various tasks.
 
 @note Because processing processors can be used in other contexts, a binder is not required to configure or use a processing processor.
 */
@property (weak, nullable, readwrite) RNDBinder * binder;

/**
 @abstract A user definable name that is used during error reporting and logging.
 
 @discussion Every processor processor has an automatically generated binding name that can be used to trace errors at runtime. In addition, if a processor processor is constructed in the RNDWorkbench, a name is automatically generated that can be referenced between runtime and compile time to locate a processor that generated an error.
 
 When a processor is created programatically, a binding name is only generated at runtime and therefore varies between application runs. By setting a binding name in source code, you can enable the tracing of errors at runtime back to a specific processor within the source code.
 */
@property (strong, nullable, readwrite) NSString *bindingName;

/**
 @abstract The name used during argument replacement for a processor's template.
 
 @discussion For processor processors that have templates, any binding object value of any processor argument may be referred to using the argument name set for a respective argument processor. For example, if an argument processor has the the name "BoxWidth", it may be referred to in the template by prepending the processors argument name with a $ as shown below:
 
 @code
 
 $BoxWidth
 
 @endcode
 
 @note Argument names should not have any spaces, but may otherwise be composed of any characters compatible with NSString's replaceOccurencesOfString:withString:options:range.
 
 */
@property (strong, nullable, readwrite) NSString *argumentName;

/**
 @abstract All binding processors used as nodes by a binding processor.
 
 @discussion A binding processor uses other binding processors for a number of functions including construction of arguments for templates, evaluation predicates, placeholders, etc. These are collectively referred to as the binding processor's processorNodes, which this property returns.
 */
@property (strong, nonnull, readonly) NSArray<RNDBindingProcessor *> *processorNodes;


#pragma mark - Observed Object Management

/**
 @abstract The observed object is an object that exposes a KVC-compliant property (that property can be self) that can be read from and optionally monitored using KVO.
 
 @discussion In standard usage, the observed object is a controller or model object that provides or receives data to/from a processor. A common example of this usage is the binding of a view object to a mediating controller (for example, an RNDObjectController). In this scenario, a processor is used to read data from the controller when requested by the view object (through an RNDBinder) and to optionally monitor the controller for changes which are forwarded to the view so it's value remains synchronized with the mediating controller. An additional processor is used to write changes that originate from the view to the mediating controller (through the same RNDBinder). In this scenario, the two processors and the binder create a binding between the mediating controller and the view object, enabling synchronization of a value.
 
 It is also possible, and often very useful to create processor processors that use an observed object as a value source or update trigger. As a value source, an observed object can be used as an evaluation object, for example the source of text that a regular expression should be evaluated against. As an update trigger, an observed object can be used solely for the purpose of monitoring some property for changes that should trigger some action. These two activities can be used together, or they can be used apart to create more nuanced processing flows.
 
 @warning A keypath must be set when setting an observed object, even if the keypath is "self".
 
 */
@property (strong, nullable, readwrite) NSObject *observedObject;

/**
 @abstract A KVC compliant keypath pointing to a KVC and optionally KVO compliant property on the observed object.
 
 @discussion The observed object keypath is applied to the observed object via the valueForKeyPath: and/or setValue:forKeyPath Key-Value Coding (KVC) methods. If a processor is being used to get a value from the observed object, any of the KVC operators that are compatible with the property referred to by the keypath may be used. For example, if an object has property "testScores" that is an array of numbers, the "\@avg" operator may be used on the array of numbers to return the array's average by setting the keypath to:
 
 @code
 
 @avg.testScores
 
 @endcode
 
  The "self" keyword can be used to refer to the observed object itself, enabling operators to be applied to it. For example, if the observed object is an array of numbers, the following would result in the average of the array's values.
 
 @code
 
 @avg.self
 
 @endcode
 
 @note It is not possible to observe the result of a collection operator as the result is transient.
 
 @warning A keypath must be set when setting an observed object, even if the keypath is "self".
 
 @warning Operators must not be used for processors that set values as they are meaningless for the setter method and will result in an exception when executed.
 */
@property (strong, nullable, readwrite) NSString * observedObjectKeyPath;

/**
 @abstract The identifier used by the processor to request an observed object from a binder.
 
 @discussion Nodes support automatic configuration when unarchived during the Nib loading process. Part of this configuration includes requesting the observed object the processor was configured to work with from its binder. Typically, the binder will forward the request to its observer object which was configured in a Xib or Storyboard at design-time.
 
 The observer object will usually have a collection of bindable objects, keyed by their unique binding identifier. The observedObjectBindingIdentifier will match one of the keys in the observer object's bindable objects collection, enabling the processor to retrieve its observed object.
 
 */
@property (strong, nullable, readwrite) NSString *observedObjectBindingIdentifier;

/**
 @abstract The result of sending the valueForKeyPath: message to the observed object.
 
 @discussion The observedObjectEvaluationValue is the result of requesting the value specified by the observedObjectKeyPath from the observedObject. This value is used when the processor is configured to use the CalculatedValueOutputType, and it is also passed as an argument to the observedObjectEvaluator using the key $OO_BINDING_VALUE.
 */
@property (strong, nullable, readonly) id observedObjectBindingValue;

/**
 @abstract Determines if the observed object's property will be monitored using Key-Value Observing.
 
 @discussion A processor processor can optionally monitor an observed object's KVC-compliant and KVO-compliant property specified by the observed object keypath. Setting monitorsObservedObject to true will cause the processor to register as a Key-Value Observer for the observed object property when the processor receives a bindObjects message, and to unregister as an observer when it receives an unbindObjects message.
 
 Because many objects are not KVC and KVO compliant, care should be taken when enabling monitoring. In general, it is best to only monitor objects that are known to be compliant with the two protocols, or to perform  testing to ensure that objects behave in a compliant manner.
 
 @note It is not possible to use KVO without a valid property keypath. KVO monitors relationships, not objects, and therefore it is not possible to monitor the observed object itself, only its relationships to other objects (its properties).
 */
@property (readwrite) BOOL monitorsObservedObject;

/**
 @abstract Ensures that any valueForKey: message to the observed object is performed on the main queue.
 
 @discussion Depending on the type of observed object, it may be necessary to confine all reading of values to the main queue. Because the main queue executes serially (and has other important features like a runloop), it is often used as an application wide synchronization queue. Setting the readOnMainQueue to YES ensures that all "reads" of an observed object's property value will be performed on the main queue.
 */
@property (readwrite) BOOL readOnMainQueue;

/**
 @abstract Ensures that any setValue:ForKey: message to the observed object is performed on the main queue.
 
 @discussion Depending on the type of observed object, it may be necessary to confine all writing of values to the main queue. Because the main queue executes serially (and has other important features like a runloop), it is often used as an application wide synchronization queue. Setting the writeOnMainQueue to YES ensures that all "writes" to an observed object's property value will be performed on the main queue.

 */
@property (readwrite) BOOL writeOnMainQueue;

/**
 @abstract Determines which controller proxy the processor reads from and observes.
 
 @discussion When a processor's observed object connects to an RNDObjectController or RNDResourceController, it must specify the type of model proxy it wishes to interact with. These controllers can provide arrangedObjects, selection, content, selectedObjects, and other proxy objects depending on the controller type.
 
 The controller key is not a part of the model's keypath, but is instead a part of the keypath that is constructed for the controller. Controllers remove the controller key prior to reading a value from the model or setting up any internal model value observation.
 
 Subclasses can use the key to differentiate between information from a controller that has been constrained (selection, selectedObjects, arrangedObjects, etc.) and information from a controller that represents the entirety of the underlying model (content).
 
 */
@property (strong, nullable, readwrite) NSString *controllerKey;

@property (strong, nullable, readonly) NSString *resolvedObservedObjectKeyPath;


#pragma mark - Object Lifecycle

- (instancetype _Nullable)init NS_DESIGNATED_INITIALIZER;

- (instancetype _Nullable)initWithCoder:(NSCoder * _Nullable)aDecoder NS_DESIGNATED_INITIALIZER;
-(void)encodeWithCoder:(NSCoder * _Nonnull)aCoder;

#pragma mark - Binding Management

/**
 @abstract Indicates if the processor is in a bound state.
 
 @discussion When a processor has been bound, its properties can not be mutated with the single exception of its runtime arguments.
 
 */
@property (readonly, getter=isBound) BOOL bound;

/**
 @abstract Causes the binding processor to attempt to enter into a bound state.
 
 @discussion This method calls the bind:error method.
 */
- (void)bind;

/**
 @abstract Causes the binding processor to attempt to enter into a bound state.

 @param error Takes a pointer that will be set to an error object in the event of binding failure.
 
 @return YES is the binding was successful, NO otherwise.
 
 @discussion This method calls the bindObjects:error method using a dispatch barrier on the synch queue.
 
 */
- (BOOL)bind:(NSError * __autoreleasing _Nullable * _Nullable)error;

/**
 @abstract Causes the binding processor to exit the bound state.
 
 @discussion This method calls the unbind:error method.
 
 */
- (void)unbind;

/**
 @abstract Causes the binding processor to exit the bound state.

 @param error Takes a pointer that will be set to an error object in the event of an error during unbinding.
 
 @return YES if the unbinding occurs without error, NO otherwise.
 
 @discussion This method calls the unbindObjects:error method using a dispatch barrier on the synch queue.
 
 */
- (BOOL)unbind:(NSError * __autoreleasing _Nullable * _Nullable)error;

/**
 @abstract Causes the binding processor to attempt to enter into a bound state.

 @param error Takes a pointer that will be set to an error object in the event of an error during unbinding.

 @return YES is the binding was successful, NO otherwise.

 @discussion When a binding processor receives a bind message it will confirm the presence of a binder object, attempt to connect to its observed object, add itself as an observer for its observed object if necessary, and call bind on all of its processor nodes. If binding is successful, this method sets the isBound property to YES and return a YES value.
 
 If an error occurs at any of these steps, the binding processor will revert to its unbound state and request that its processor nodes do the same. It will then set the error and return a NO value.

 */
- (BOOL)bindObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;

/**
 @abstract Causes the binding processor to exit the bound state.
 
 @param error Takes a pointer that will be set to an error object in the event of an error during unbinding.
 
 @return YES if the unbinding occurs without error, NO otherwise.
 
 @discussion When a binding processor receives an unbind message, it passes the unbind message to all of its processor nodes and removes itself as an observer if necessary from the observed object. If this process occurs without an error, then the method returns YES.
 
 If an error occurs at any of these steps, the error will be set and the method will return NO.
 
 In either case, the binding processor will exit the bound state.

 */
- (BOOL)unbindObjects:(NSError * __autoreleasing _Nullable * _Nullable)error;


#pragma mark - Value Management

@property (readwrite) RNDValueMode processorValueMode;

/**
 @abstract Determines if a processor will evaluate its raw value to create a calculated value.
 
 @discussion Certain processor types can product two versions of a binding value. The first version, called the RawValueOutputType generally conforms to the related class of the processor. For example, a RNDPredicateNode's raw value is an NSPredicate. The second version, called the CalculatedValueOutputType, is the result of evaluating the raw value. For example, the RNDPredicateNode's calculated value would be a YES or NO wrapped in an NSNumber.
 
 */
@property (readwrite) RNDProcessorOutputType processorOutputType;

/**
 @abstract A predicate processor that is evaluated against the observed object binding value. A NO result causes the processor to abort processing and to return nil or, if a nil placeholder is set, to return the placeholder.
 
 @discussion The observed object evaluator is used to determine if a processor should attempt to resolve its binding object value. While the predicate is evaluated against the observed object binding value, it does not need to use it in the construction of the predicate. However, if use of the observed object binding value is required, it can be included in the predicate via the SELF format specifier.
 */
@property (strong, nullable, readwrite) RNDPredicateProcessor *processorCondition;

/**
 @abstract Processors that are used as arguments during the processing of a binding object value.
 
 @discussion A processor may have one or more processors whose binding object values can be used as substitutions in templates or other processes. Use the boundArguments array when the processor is bound to determine what arguments, if any are being used by the processor.
 */
@property (strong, nullable, readonly) NSMutableArray<RNDBindingProcessor *> *processorArguments;

/**
 @abstract The processors used as arguments when bound.
 
 @discussion When a processor is bound, it creates a read only copy of its processor arguments array that is used for the duration of the binding. When the processor is not bound, this property is nil.
 */
@property (strong, nullable, readonly) NSArray<RNDBindingProcessor *> *boundProcessorArguments;

/**
 @abstract The curent arguments assigned to the processor for its use during the construction of the processor node's binding object value.
 
 @discussion When a processor constructs its binding object value, it can use arguments that are passed to it at runtime. This enables the construction of binding object values that are dependent upon information that can only be known at runtime, such as device orientation, size of a view, etc. While most runtime information can be retrieved by processors by traversing object hierarchies, runtime arguments provide a useful, and often more performant means of passing information to processors.
 
 To the use the runtime arguments dictionary, create a new dictionary by combining the existing runtime arguments dictionary with any additional key-value pairs, assigning the resulting dictionary to the runtime arguments dictionary.
 */
@property (strong, null_resettable, readwrite) NSDictionary<NSString *, id> *runtimeArguments;

/**
 @abstract The key that should be associated with the processorValue.
 
 @discussion In many cases, a processor processor's value will need to be associated with a key when used as the inflow value processors of a binder. The user string is generated via a RNDPatternedStringNode that can dynamically construct an approprite key based on processor and runtime arguments.
 */
@property (strong, nullable, readwrite) RNDPatternedStringProcessor *bindingValueLabel;

/**
 @abstract The result of processing processors configuration.
 
 @discussion Nodes have a binding object value that results from the processing of the processors configuration and its intersection with the current state of the runtime and object graph. A processor's binding object value is typically constructed using the following process:
 
 1. Should the processor evaluate? If it should not evaluate, is there a nil placeholder whose binding object value should be processed and returned in its place? If there is, return the nil placeholder's binding object value; otherwise, return nil.
 
 2. If the processor should evaluate, process and capture all of the processor's argument's binding object values and all of the runtime arguments. Then, depending on the processor type, perform all argument replacements to create a raw value.
 
 3. If the processor's output type is CalculatedValueOutputType, evaluate the processor's raw value to create an object value. Otherwise, assign the raw value to the object value.
 
 4. If the object value is any one of the known markers and a placeholder has been set for the marker, replace the object value with the placeholder. In either case, return the object value as the processor's binding object value.
 
 5. If the object value is not one of the known markers and a transformer is set for the processor processor, transform the object value, assigning the transformed output to the object value.
 
 6. If the object value is nil and a nil placeholder has been set, then assign the binding object value of the nil placeholder to the processor's object value. Return the object value as the processor's binding object value.
 
 */
@property (readonly, nullable) id bindingValue;

- (id _Nullable)coordinatedBindingValue;
- (id _Nullable)rawBindingValue:(id _Nullable)bindingValue;
- (id _Nullable)calculatedBindingValue:(id _Nullable)bindingValue;

#pragma mark - Value Filtering

/**
 @abstract A processor processor whose binding object value is used when a processor processor's binding object value is equal to the RNDBindingNullValueMarker.
 
 @discussion A null value marker is used to indicate that an expected/required value is null. This is in constrast to a nil value which indicates the absence or failure to produce a value. When a null value marker is produced during binding object value processing, the binding object value of a processor set as the null placeholder is substituted for the null value marker. Sometimes this is simply the replacement of the null value marker with an instance of the NSNull class. In other scenarios, an alternate evaluation path is process to return a default value.
 */
@property (strong, nullable, readwrite) RNDBindingProcessor *nullPlaceholder;

/**
 @abstract A processor processor whose binding object value is used when a processor processor's binding object value is equal to the RNDBindingMultipleValuesMarker.
 
 @discussion A multiple values marker is used to indicate that multiple values could not be coalesced into a valid binding object value for the processor. When a multiple values marker is produced during binding object value processing, the binding object value of a processor set as the multiple selection placeholder is substituted for the multiple values marker. Sometimes this is simply the replacement of the marker with a string that indicates the presence of multiple values. In other scenarios, an alternate evaluation path is process to return a default value.
 */
@property (strong, nullable, readwrite) RNDBindingProcessor *multipleSelectionPlaceholder;
/**
 @abstract A processor processor whose binding object value is used when a processor processor's binding object value is equal to the RNDBindingNoSelectionMarker.
 
 @discussion A no selection marker is used to indicate that there is no valid selection to read a value from or generate a value for. When a no selection marker is produced during binding object value processing, the binding object value of a processor set as the no selection placeholder is substituted for the no selection marker. Sometimes this is simply the replacement of the marker with a string that indicates the lack of a selection. In other scenarios, an alternate evaluation path is process to return a default value.
 
 */
@property (strong, nullable, readwrite) RNDBindingProcessor *noSelectionPlaceholder;

/**
 @abstract A processor processor whose binding object value is used when a processor processor's binding object value is equal to the RNDBindingNotApplicableMarker.
 
 @discussion A not applicable marker is used to indicate that the processor can not produce an applicable value. Generally this is a marker that is recieved from a controller. When a not applicable marker is produced during binding object value processing, the binding object value of a processor set as the not applicable placeholder is substituted for the no applicable marker. Sometimes this is simply the replacement of the marker with a string that indicates that their is not an applicable value. In other scenarios, an alternate evaluation path is process to return a default value.
 
 */
@property (strong, nullable, readwrite) RNDBindingProcessor *notApplicablePlaceholder;

/**
 @abstract A processor processor whose binding object value is used when a processor processor's binding object value is equal to nil.
 
 @discussion When a nil value is produced during binding object value processing, the binding object value of a processor set as the nil placeholder is substituted for the nil value. Sometimes this is simply the replacement of nil with a string that indicates the presence of a nil value. In other scenarios, an alternate evaluation path is process to return a default value.
 
 */
@property (strong, nullable, readwrite) RNDBindingProcessor *nilPlaceholder;

- (id _Nullable)filteredBindingValue:(id _Nullable)bindingValue;


#pragma mark - Value Transformation
/**
 @abstract A registered name of a value transformer that should be used by the processor processor.
 
 @discussion To use a value transformer with a processor processor, set the value transformer name. At runtime, the value transformer will be added to the processor processor.
 */
@property (strong, nullable, readwrite) NSString *valueTransformerName;

/**
 @abstract The value transformer used by the processor processor during the processing of the processors binding object value.
 
 @discussion A value transformer is retrieved at runtime based on the value transformer name that has been set for the processor.
 */
@property (strong, nullable, readonly) NSValueTransformer *valueTransformer;

- (id _Nullable)transformedBindingValue:(id _Nullable)bindingValue;

#pragma mark - Value Wrapping

@property (readwrite) BOOL unwrapSingleValue;

- (id _Nullable)wrappedBindingValue:(id _Nullable)bindingValue;

@end

