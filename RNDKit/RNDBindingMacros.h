//
//  RNDBindingMacros.h
//  RNDKit
//
//  Created by Erikheath Thomas on 2/7/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#ifndef RNDBindingMacros_h
#define RNDBindingMacros_h


#endif /* RNDBindingMacros_h */

#define RNDCoordinatedProperty(propertyType, getterName, setterName) @synthesize getterName = _ ## getterName; \
  \
- ( propertyType ) getterName {  \
[_coordinatorLock lock];  \
propertyType localObject = _ ## getterName;  \
[_coordinatorLock unlock];  \
return localObject;  \
}  \
  \
- (void)set ## setterName:( propertyType ) getterName {  \
[_coordinatorLock lock];  \
if (self.bound == YES) { return; }  \
_ ## getterName = getterName;  \
[_coordinatorLock unlock];  \
}  \






#define RNDCoordinatedPropertyExt(propertyType, propertyName, privatePropertyName) @synthesize propertyName = privatePropertyName;

