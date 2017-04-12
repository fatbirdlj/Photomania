//
//  Photographer+Create.m
//  Photomania
//
//  Created by 刘江 on 2017/4/8.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer(Create)

+ (Photographer *)photographerWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    Photographer *photographer = nil;
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.predicate = [NSPredicate predicateWithFormat:@"name =%@",name];
        
        NSArray *match = [managedObjectContext executeFetchRequest:request error:NULL];
        if (!match || [match count] > 1) {
        } else if(![match count]){
            photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:managedObjectContext];
            photographer.name = name;
        } else {
            photographer = [match lastObject];
        }
    }
    return photographer;
}

+ (Photographer *)userInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext{
    return [Photographer photographerWithName:@" My Photos" inManagedObjectContext:managedObjectContext];
}

- (BOOL)isUser{
    return self == [[self class] userInManagedObjectContext:self.managedObjectContext];
}

@end
