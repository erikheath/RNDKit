//
//  DetailViewController.h
//  GuessWhat
//
//  Created by Erikheath Thomas on 5/3/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UNSModel/UNSListing+CoreDataClass.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) UNSListing *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

