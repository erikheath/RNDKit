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
        }
        return nil;
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
        }
        return nil;
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
        }
        return nil;
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

- (NSDictionary *)valuesForEntity:(NSEntityDescription *)entity responseData:(NSData *)responseData error:(NSError **)error {
    
    //****************** BEGIN RESPONSE DATA PROCESSING ******************//
    NSError *dataProcessingError = nil;
    NSString *dataContainerType = entity.userInfo[@"dataContainerType"];
    
    NSDictionary *values = nil;
    
    if (dataContainerType == nil || [dataContainerType isEqualToString:@"JSON"] == YES) {
        values = [self valuesForEntity:entity JSONData:responseData error:&dataProcessingError];
    } else if ([dataContainerType isEqualToString:@"IMAGE"]) {
        values = [self valueForEntity:entity archivedData:responseData error:&dataProcessingError];
    }
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (dataProcessingError != nil) {
        if (error != NULL) {
            *error = dataProcessingError; // TODO: Return error
        }
        return nil;
    }

    if (values.count < 1) { return nil; }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    return values;
    
    //****************** END RESPONSE DATA PROCESSING ******************//

}

- (NSDictionary *)valuesForEntity:(NSEntityDescription *)entity JSONData:(NSData *)JSONData error:(NSError **)error {
    //****************** BEGIN JSON TO OBJECT CONVERSION ******************//
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (JSONData == nil) {
        if (error != NULL) {
            *error = nil; // TODO: Return error
        }
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    NSError *JSONError = nil;
    id JSONResult = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&JSONError];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if(JSONError != nil) {
        if (error != NULL) {
            *error = JSONError;
        }
        return nil;
    }

    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END JSON TO OBJECT CONVERSION ******************//
    
    
    //****************** BEGIN RESPONSE DATA ROOT PROCESSING ******************//
    NSString *dataRootKeyPath = entity.userInfo[@"dataRootKeyPath"];
    id dataRootObject = [JSONResult valueForKeyPath:dataRootKeyPath];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (dataRootObject == nil) {
     if (error != NULL) {
            *error = nil; // TODO: Return error
     }
        return nil;
    }
    
    if ([dataRootObject isKindOfClass:[NSArray class]]) {
        dataRootObject = ((NSArray *)dataRootObject).firstObject;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END RESPONSE DATA ROOT PROCESSING ******************//
    
    
    //****************** BEGIN RESPONSE DATA OBJECT PROCESSING ******************//
    NSMutableDictionary *values = [NSMutableDictionary new];
    
    for (NSAttributeDescription *attribute in entity) {
        id objectValue = nil;
        NSString *serverKeyPath = attribute.userInfo[@"serverKeyPath"];
        if (serverKeyPath != nil) { objectValue = [dataRootObject valueForKeyPath:serverKeyPath]; }
        if (objectValue != nil) { [values setObject:objectValue forKey:attribute.name]; }
    }
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (values.count < 1) { return nil; }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    return values;
    
    //****************** END RESPONSE DATA OBJECT PROCESSING ******************//
}

- (NSDictionary *)valueForEntity:(NSEntityDescription *)entity archivedData:(NSData *)data error:(NSError **)error {
    
    //****************** BEGIN RESPONSE DATA OBJECT PROCESSING ******************//
    NSMutableDictionary *values = [NSMutableDictionary new];
    
    for (NSAttributeDescription *attribute in entity) {
        id objectValue = nil;
        NSString *serverKeyPath = attribute.userInfo[@"serverKeyPath"];
        if (serverKeyPath != nil) { objectValue = data; }
        if (objectValue != nil) { [values setObject:objectValue forKey:attribute.name]; }
    }
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (values.count < 1) { return nil; }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    return values;
    
    //****************** END RESPONSE DATA OBJECT PROCESSING ******************//
}


- (NSDictionary <NSManagedObjectID *, NSDate *> *)lastUpdatesForEntity:(NSEntityDescription *)entity
                                                             objectIDs:(NSArray <NSManagedObjectID *> *)objectIDs
                                                          responseData:(NSData *)data
                                                                 error:(NSError **)error {
    
    //****************** BEGIN JSON TO OBJECT CONVERSION ******************//
    NSError *JSONError = nil;
    id JSONResult = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (JSONError != nil) {
        if (error != NULL) {
            *error = JSONError; // TODO: Return error
        }
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END JSON TO OBJECT CONVERSION ******************//
    
    
    //****************** BEGIN RESPONSE DATA ROOT PROCESSING ******************//
    NSString *lastUpdateKeyPath = entity.userInfo[@"lastUpdateKeyPath"];
    id lastUpdates = [JSONResult valueForKeyPath:lastUpdateKeyPath];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (lastUpdates == nil) {
        if (error != NULL) {
            *error = nil; // TODO: Return error
        }
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END RESPONSE DATA ROOT PROCESSING ******************//
    
    
    //****************** BEGIN RESPONSE DATA OBJECT PROCESSING ******************//
    NSArray *updatesArray = nil;
    
    if ([lastUpdates isKindOfClass:[NSString class]] == YES) {
        updatesArray = @[lastUpdates];
        
    } else if ([lastUpdates isKindOfClass:[NSNumber class]] == YES) {
        updatesArray = @[lastUpdates];
        
    } else if ([lastUpdates isKindOfClass:[NSArray class]] == YES) {
        updatesArray = (NSArray *)lastUpdates;
    }
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (updatesArray == nil) {
        if (error != NULL) {
            *error = nil; // TODO: Return error
        }
        return nil;
    }
    
    if (updatesArray.count != objectIDs.count) {
        if (error != NULL) {
            *error = nil; // TODO: Return error
        }
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END RESPONSE DATA OBJECT PROCESSING ******************//

    
    //****************** BEGIN VALUES OBJECT PROCESSING ******************//
    NSDictionary *updateDictionary = [NSDictionary dictionaryWithObjects:updatesArray forKeys:objectIDs];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (updateDictionary.count < 1) { return nil; }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    return updateDictionary;
    
    //****************** END VALUES OBJECT PROCESSING ******************//
    
}

@end
