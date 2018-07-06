//
//  MasterViewController.h
//  GuessWhat
//
//  Created by Erikheath Thomas on 5/3/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UNSModel/UNSListing+CoreDataClass.h"
#import "UNSModel/UNSProperty+CoreDataClass.h"
#import "UNSModel/UNSImage+CoreDataClass.h"
#import "UNSModel/UNSSearchProfile+CoreDataClass.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController<UNSSearchProfile *> *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

