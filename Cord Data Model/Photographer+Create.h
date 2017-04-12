//
//  Photographer+Create.h
//  Photomania
//
//  Created by 刘江 on 2017/4/8.
//  Copyright © 2017年 Flicker. All rights reserved.
//
#import "Photographer+CoreDataClass.h"
#import <CoreData/CoreData.h>

@interface Photographer(Create)

+ (Photographer *)userInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (BOOL)isUser;

+ (Photographer *)photographerWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
