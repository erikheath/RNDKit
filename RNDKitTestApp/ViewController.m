//
//  ViewController.m
//  RNDKitTestApp
//
//  Created by Erikheath Thomas on 10/26/17.
//  Copyright © 2017 Curated Cocoa LLC. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

//enum RNDObjCValueType {
//    NSObjCNoType = 0,
//    NSObjCVoidType = 'v',
//    NSObjCCharType = 'c',
//    NSObjCShortType = 's',
//    NSObjCLongType = 'l',
//    NSObjCLonglongType = 'q',
//    NSObjCFloatType = 'f',
//    NSObjCDoubleType = 'd',
//    NSObjCBoolType = 'B',
//    NSObjCSelectorType = ':',
//    NSObjCObjectType = '@',
//    NSObjCStructType = '{',
//    NSObjCPointerType = '^',
//    NSObjCStringType = '*',
//    NSObjCArrayType = '[',
//    NSObjCUnionType = '(',
//    NSObjCBitfield = 'b'
//};

typedef struct {
    NSInteger type;
    union {
        char charValue;
        short shortValue;
        long longValue;
        long long longlongValue;
        float floatValue;
        double doubleValue;
        bool boolValue;
        SEL selectorValue;
//        id objectValue;
        void *pointerValue;
        void *structLocation;
        char *cStringLocation;
    } value;
} RNDObjCValue ;
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

- (void)takeAStructure:(CGRect)myRect andObject:(id)myObject {
    NSLog(@"");
}

- (IBAction)myAction:(id)sender forEvent:(UIEvent *)event {
    CGRect myRect = CGRectMake(0, 0, 0, 0);
    NSValue *myValue = [NSValue valueWithCGRect:myRect];
    CGRect rect;
    [myValue getValue:&rect size:sizeof(CGRect)];
    float myArray[] = {0,1,2,3,4,5};
    NSValue *myArrayValue = [NSValue value:myArray withObjCType:"[6f]"];
    float newArray[6];
    [myArrayValue getValue:&newArray size:sizeof(float)*6];
    NSString *myString = @"Hello";
    SEL selector = @selector(takeAStructure:andObject:);
    NSMethodSignature *signature = [ViewController instanceMethodSignatureForSelector:selector];
    NSInvocation *myInvoc = [NSInvocation invocationWithMethodSignature:signature];
    NSValue *mySelector = [NSValue valueWithPointer:&selector];
    SEL *otherSelect = NULL;
    [mySelector getValue:&otherSelect size:sizeof(SEL)];
    SEL anotherSelect = *otherSelect;
    
    RNDObjCValue myObjCValue;
    myObjCValue.value.selectorValue = anotherSelect;
    [myInvoc setArgument:&myObjCValue.value.selectorValue atIndex:2];
    SEL theNextOne;
    [myInvoc getArgument:&theNextOne atIndex:2];
    NSLog(@"Let's Pause");
}

@end
