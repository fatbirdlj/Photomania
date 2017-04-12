//
//  CoreDataTableViewController.h
//  Photomania
//
//  Created by 刘江 on 2017/4/7.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataTableViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (strong,nonatomic) NSFetchedResultsController *fetchtedResultsController;

- (void)performFetch;

@property BOOL debug;

@end
