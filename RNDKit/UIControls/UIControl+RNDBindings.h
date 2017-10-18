//
//  UIControl+RNDBindings.h
//  RNDKit
//
//  Created by Erikheath Thomas on 10/16/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNDBindings.h"

@interface UIControl (RNDBindings)
@property (readwrite, nullable) id controlValue; // This is the 'value' of a control. This property should be overridden with the correct intrinsic control value - for example, for a text field it is the text, for a checkbox it is the state, etc.
@property (readwrite, nullable) id controlValueFormatter;
@property (copy, nullable) NSString *controlStringValue;
@property (copy, nullable) NSAttributedString *controlAttributedStringValue;
@property int controlIntValue;
@property NSInteger controlIntegerValue;
@property float controlFloatValue;
@property double controlDoubleValue;

- (void)takeControlIntValueFrom:(nullable id)sender;
- (void)takeControlFloatValueFrom:(nullable id)sender;
- (void)takeControlDoubleValueFrom:(nullable id)sender;
- (void)takeControlStringValueFrom:(nullable id)sender;
- (void)takeControlObjectValueFrom:(nullable id)sender;
- (void)takeControlIntegerValueFrom:(nullable id)sender;

@end
