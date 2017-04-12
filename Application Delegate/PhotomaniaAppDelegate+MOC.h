//
//  PhotomaniaAppDelegate+MOC.h
//  Photomania
//
//  Created by 刘江 on 2017/4/10.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "PhotomaniaAppDelegate.h"

@interface PhotomaniaAppDelegate (MOC)

- (NSManagedObjectContext *)createMainQueueManagedObjectContext;

@end
