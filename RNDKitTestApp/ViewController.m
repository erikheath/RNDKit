//
//  ViewController.m
//  RNDKitTestApp
//
//  Created by Erikheath Thomas on 10/26/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

//@synthesize myString = _myString;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)myAction:(id)sender forEvent:(UIEvent *)event {
        NSLog(@"Let's Pause");
}

@end
