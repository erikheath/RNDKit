//
//  RNDJSONResponseProcessor.m
//  RNDKit
//
//  Created by Erikheath Thomas on 5/9/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import "RNDJSONResponseProcessor.h"

@implementation RNDJSONResponseProcessor

- (NSArray <NSString *> *)uniqueIdentifiersForEntity:(NSEntityDescription *)entity
                                        responseData:(NSData *)responseData
                                               error:(NSError **)error {
    
    //****************** BEGIN JSON TO OBJECT CONVERSION ******************//
    NSError *JSONError = nil;
    id JSONResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&JSONError];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////

    if(JSONError != nil) {
        if (error != NULL) {
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDJSONDeserializationError":[NSString stringWithFormat:@"Entity(%@) response data could not be deserialized.", entity.name], NSUnderlyingErrorKey:JSONError}];
            *error = internalError;
        }
        return nil;
    }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    //****************** END JSON TO OBJECT CONVERSION ******************//

    
    //****************** BEGIN RESPONSE DATA ROOT PROCESSING ******************//

    NSString *identifierKeyPath = entity.userInfo[@"identifierKeyPath"];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////

    if (identifierKeyPath == nil) {
        if (error != NULL) {
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDIsNilError":@"entity.userInfo[@\"identifierKeyPath\""}];
            *error = internalError;
        }
        return nil; }
    
    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    id identifierRootObject = [JSONResult valueForKeyPath:identifierKeyPath];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////

    if (identifierRootObject == nil) {
        if (error != NULL) {
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDJSONValueRetrievalError":[NSString stringWithFormat:@"Root object not found for key path(%@) in entity (%@) parsed response data.", identifierKeyPath, entity.name]}];
            *error = internalError;
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
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDJSONFormatError":[NSString stringWithFormat:@"Entity(%@) response data for identifier key path (%@) does not contain the expected format.", entity.name, identifierKeyPath]}];
            *error = internalError;
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
            *error = dataProcessingError;
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
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDJSONDataError":@"JSON data is nil."}];
            *error = internalError;
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
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDJSONDeserializationError":@"Parsed JSON data is nil."}];
            *error = internalError;
        }
        return nil;
    }

    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    
    //****************** END JSON TO OBJECT CONVERSION ******************//
    
    
    //****************** BEGIN RESPONSE DATA ROOT PROCESSING ******************//
    NSString *dataRootKeyPath = entity.userInfo[@"dataRootKeyPath"];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////

    if (dataRootKeyPath == nil) {
        if (error != NULL) {
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDIsNilError":@"entity.userInfo[@\"dataRootKeyPath\""}];
            *error = internalError;
        }
        return nil;
    }

    /////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////

    id dataRootObject = [JSONResult valueForKeyPath:dataRootKeyPath];
    
    //////////////////////////////////////////////////////
    ///////////////////// CHECKPOINT /////////////////////
    //////////////////////////////////////////////////////
    
    if (dataRootObject == nil) {
     if (error != NULL) {
         NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDJSONValueRetrievalError":[NSString stringWithFormat:@"Root object not found for key path(%@) in entity (%@) parsed response data.", dataRootKeyPath, entity.name]}];
         *error = internalError;
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
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDJSONDeserializationError":@"Parsed JSON data is nil.", NSUnderlyingErrorKey:JSONError}];
            *error = internalError;
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
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDIsNilError":@"entity.userInfo[@\"lastUpdateKeyPath\""}];
            *error = internalError;
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
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDJSONFormatError":[NSString stringWithFormat:@"Entity(%@) response data for identifier key path (%@) does not contain the expected format.", entity.name, lastUpdateKeyPath]}];
            *error = internalError;
        }
        return nil;
    }
    
    if (updatesArray.count != objectIDs.count) {
        if (error != NULL) {
            NSError *internalError = [NSError errorWithDomain:@"RNDCoreDataDomain" code:200000 userInfo:@{@"RNDJSONFormatError":[NSString stringWithFormat:@"Updates do not match specified Object IDs."]}];
            *error = internalError;
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
