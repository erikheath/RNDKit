//
//  ViewController.h
//  RNDKitTestApp
//
//  Created by Erikheath Thomas on 10/26/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property(readwrite, nullable) IBOutlet NSString *myString;

- (IBAction)myAction:(id _Nullable )sender forEvent:(UIEvent *_Nullable)event;

@end

