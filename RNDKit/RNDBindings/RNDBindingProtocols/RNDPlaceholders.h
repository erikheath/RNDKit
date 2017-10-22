//
//  RNDPlaceholders.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/20/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RNDPlaceholders <NSObject>

- (void)setplaceholder:(id _Nullable)placeholder forMarker:(RNDBindingMarker _Nonnull)marker withBinding:(RNDBindingName _Nonnull)bindingName;    // marker can be nil or one of RNDMultipleValuesMarker, RNDNoSelectionMarker, RNDNotApplicableMarker
- (id _Nullable)placeholderForMarker:(RNDBindingMarker _Nonnull)marker withBinding:(RNDBindingName _Nonnull)bindingName;    // marker can be nil or one of RNDMultipleValuesMarker, RNDNoSelectionMarker, RNDNotApplicableMarker


@end

