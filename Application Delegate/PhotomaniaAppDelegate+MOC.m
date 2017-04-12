//
//  PhotomaniaAppDelegate+MOC.m
//  Photomania
//
//  Created by 刘江 on 2017/4/10.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "PhotomaniaAppDelegate+MOC.h"
#import <CoreData/CoreData.h>

@implementation PhotomaniaAppDelegate (MOC)

- (NSManagedObjectContext *)createMainQueueManagedObjectContext{
    NSManagedObjectContext *managedObjectContext = nil;
    NSPersistentStoreCoordinator *coordinator = [self createPersistentStoreCoordinator];
    if (coordinator) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
    NSManagedObjectModel *managedObjectModel = [self createManagedObjectModel];
    NSURL *storeURL = [[self applicationDocumentDirectory] URLByAppendingPathComponent:@"MOC.sqlite"];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@ %@",error,[error userInfo]);
        abort();
    }
    return  persistentStoreCoordinator;
}

- (NSManagedObjectModel *)createManagedObjectModel{
    NSManagedObjectModel *managedObjectModel = nil;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Photomania" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

- (NSURL *)applicationDocumentDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end


