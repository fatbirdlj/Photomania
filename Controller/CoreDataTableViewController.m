//
//  CoreDataTableViewController.m
//  Photomania
//
//  Created by 刘江 on 2017/4/7.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface CoreDataTableViewController ()

@end

@implementation CoreDataTableViewController

- (void)performFetch{
    if (self.fetchtedResultsController) {
        if (self.fetchtedResultsController.fetchRequest.predicate) {
            if (self.debug) {
                NSLog(@"[%@ %@] fetching %@ with predicate: %@",
                      NSStringFromClass([self class]),NSStringFromSelector(_cmd),
                      self.fetchtedResultsController.fetchRequest.entityName,
                      self.fetchtedResultsController.fetchRequest.predicate);
            }
        } else {
            if (self.debug) {
                NSLog(@"[%@ %@] fetcing all %@ (i.e., no predicate)",
                      NSStringFromClass([self class]),NSStringFromSelector(_cmd),
                      self.fetchtedResultsController.fetchRequest.entityName);
            }
        }
        
        NSError *error;
        BOOL success = [self.fetchtedResultsController performFetch:&error];
        if (!success) {
            NSLog(@"[%@ %@] performFetch: failed",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        }
        if (error) {
            NSLog(@"[%@ %@] %@ (%@)",NSStringFromClass([self class]),NSStringFromSelector(_cmd),
                  [error localizedDescription],[error localizedFailureReason]);
        }
    } else {
        if (self.debug) {
            NSLog(@"[%@ %@] no NSFetchedResultsController (yet)?",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
        }
    }
    [self.tableView reloadData];
}

- (void)setFetchtedResultsController:(NSFetchedResultsController *)newfrc{
    NSFetchedResultsController *oldfrc = _fetchtedResultsController;
    if (oldfrc != newfrc) {
        _fetchtedResultsController = newfrc;
        newfrc.delegate = self;
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name])
            && (!self.navigationController || !self.navigationItem.title)) {
            self.title = newfrc.fetchRequest.entity.name;
        }
        if (newfrc) {
            if (self.debug) {
                NSLog(@"[%@ %@] %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),oldfrc?@"updated":@"set");
            }
            [self performFetch];
        } else {
            if (self.debug) {
                NSLog(@"[%@ %@] set to nil",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
            }
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchtedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.fetchtedResultsController.sections objectAtIndex:section] numberOfObjects];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

@end
