//
//  Photo+Flickr.h
//  Photomania
//
//  Created by 刘江 on 2017/4/11.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "Photo+CoreDataClass.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrInfo: (NSDictionary *)photoDictionary inManagedObjectContext: (NSManagedObjectContext *)context;

+ (void)loadPhotosFromFlickrArray: (NSArray *)photos intoManagedObjectContext: (NSManagedObjectContext *)context;

@end
