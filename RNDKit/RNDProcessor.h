//
//  RNDProcessor.h
//  RNDKit
//
//  Created by Erikheath Thomas on 6/30/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 An RNDProcessor, or generically "processor", is a configurable node within a processing tree that accepts multiple inputs and produces a single output.

 
 Processors are immutable and must be initialized with directives and settings. To create mutable processors, use the RNDMutableProcessor subclass.
 */
@interface RNDProcessor : NSObject <NSCopying, NSMutableCopying, NSSecureCoding, NSFastEnumeration> {
    id _directives;
    BOOL _processConcurrently;
    BOOL _processInReverseOrder;
    NSMutableDictionary *_context;
}


/**
 If YES, directs the processor to process its directives concurrently.
 */
@property (readonly) BOOL processConcurrently;


/**
 If YES, directs the process to process its directives in reverse order (highest index to lowest index).
 */
@property (readonly) BOOL processInReverseOrder;


/**
 A readonly array of dictionaries containing:
 An extended key paths (EKPs) added with the RNDTargetKeyPath key that operates on a provided target.
 An optional key added with the RNDContextKey that assigns the value of the directives output to the shared context.
 */
@property (strong, readonly) NSArray<NSDictionary <NSString *, NSString *> *> *directives;


/**
 Create a new processor using the passed in directives array and execution options.

 @param directives An NSArray of Dictionaries of EKPs and optional context keys.
 @param options NSArray enumeration options
 @return A newly initialized processor or nil if initialization failed.
 */
- (instancetype)initWithDirectives:(NSArray<NSDictionary <NSString *, NSString *> *> *)directives executionOptions:(NSEnumerationOptions)options;

/**
 Executes the directives according to the enumeration options using the provided context.

 @param target An object that the processors directives should be executed upon.
 @return The value of the final directive.
 */
- (id)process:(id)target;


/**
 Registers the processor with the class, making it accessible via an extended key path (EKP) operation.

 @param processor An instance of the processor to use globally
 @param name The name the processor will be referred to as within an EKP
 @return YES if the processor was successfully registered, or NO if the processor could not be registered because a processor with the same name is already registered.
 */
+ (BOOL)registerProcessor:(RNDProcessor *)processor withName:(NSString *)name;


/**
 Unregisters, and therefore removes and makes unavailable, a processor registered with name.

 @param name The name used to register the processor
 @return YES if the processor was successfully unregistered, or NO if the processor could not be unregistered, typically because it does not exist.
 */
+ (BOOL)unregisterProcessorWithName:(NSString *)name;


/**
 Returns a processor registered with name, or nil if the processor does not exist.

 @param name The name of a registered processor
 @return A processor or nil if no processor has been registered with name.
 */
+ (RNDProcessor *)processorWithName:(NSString *)name;

@end
