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

#define RNDCoordinatedProperty(propertyType, propertyName) @synthesize propertyName = _ ## propertyName; \
  \
- ( propertyType ) propertyName {  \
propertyType __block localObject;  \
dispatch_sync(self.coordinator, ^{  \
localObject = _ ## propertyName;  \
});  \
return localObject;  \
}  \
  \
- (void)set ## propertyName:( propertyType ) propertyName {  \
dispatch_barrier_sync(self.coordinator, ^{  \
if (self.isBound == YES) { return; }  \
_ ## propertyName = propertyName;  \
    });  \
}  \






#define RNDCoordinatedPropertyExt(propertyType, propertyName, privatePropertyName) @synthesize propertyName = privatePropertyName;

