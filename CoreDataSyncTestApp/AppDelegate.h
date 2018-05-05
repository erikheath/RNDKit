//
//  AppDelegate.h
//  CoreDataSyncTestApp
//
//  Created by Erikheath Thomas on 5/2/18.
//  Copyright © 2018 Curated Cocoa LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

