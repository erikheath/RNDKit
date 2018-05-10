//
//  RNDJSONResponseProcessor.m
//  RNDKit
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDJSONResponseProcessor.h"

@implementation RNDJSONResponseProcessor

- (NSArray <NSString *> *)uniqueIdentifiersForEntity:(NSEntityDescription *)entity responseData:(NSData *)responseData error:(NSError **)error {
    
    //****************** BEGIN JSON TO OBJECT CONVERSION ******************//
    NSError *JSONError = nil;
    id JSONResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&JSONError];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////

    if(JSONError != nil) {
        if (error != NULL) {
            *error = JSONError;
            return nil;
        }
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    //****************** END JSON TO OBJECT CONVERSION ******************//

    
    //****************** BEGIN RESPONSE DATA ROOT PROCESSING ******************//

    NSString *identifierKeyPath = entity.userInfo[@"identifierKeyPath"];
    id identifierRootObject = [JSONResult valueForKeyPath:identifierKeyPath];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////

    if (identifierRootObject == nil) {
        if (error != NULL) {
            *error = nil; // TODO: Return error
            return nil;
        }
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    //****************** END RESPONSE DATA ROOT PROCESSING ******************//

    
    //****************** BEGIN RESPONSE DATA ROOT OBJECT PROCESSING ******************//
    NSArray *identifierArray = nil;
    
    if ([identifierRootObject isKindOfClass:[NSString class]] == YES) {
        identifierArray = @[identifierRootObject];
        
    } else if ([identifierRootObject isKindOfClass:[NSNumber class]] == YES) {
        identifierArray = @[identifierRootObject];
        
    } else if ([identifierRootObject isKindOfClass:[NSArray class]] == YES) {
        identifierArray = (NSArray *)identifierRootObject;        
    }
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////

    if (identifierArray == nil) {
        if (error != NULL) {
            *error = nil; // TODO: Return error
            return nil;
        }
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    //****************** END RESPONSE DATA ROOT OBJECT PROCESSING ******************//

    
    //****************** BEGIN RESPONSE DATA IDENTIFIER PROCESSING ******************//
    NSString *identifierTemplate = entity.userInfo[@"identifierTemplate"];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////

    if (identifierTemplate == nil) {
        return identifierArray;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    NSMutableArray *templatizedIdentifierArray = [NSMutableArray arrayWithCapacity:identifierArray.count];
    for (id identifier in identifierArray) {
        NSString *stringIdentifier = nil;
        if ([identifier isKindOfClass:[NSNumber class]] == YES) {
            stringIdentifier = [((NSNumber *)identifier) stringValue];
        } else {
            stringIdentifier = identifier;
        }
        stringIdentifier = [identifierTemplate stringByReplacingOccurrencesOfString:@"$IDENTIFIER" withString:stringIdentifier];
        [templatizedIdentifierArray addObject:stringIdentifier];
    }
    
    return templatizedIdentifierArray;
    
    //****************** END RESPONSE DATA IDENTIFIER PROCESSING ******************//

}

@end
