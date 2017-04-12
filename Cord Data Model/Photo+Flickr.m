//
//  Photo+Flickr.m
//  Photomania
//
//  Created by 刘江 on 2017/4/11.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context{
    
    Photo *photo = nil;
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@",unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || [matches count] > 1) {
        
    } else if([matches count]){
        photo = [matches firstObject];
    } else {
        if ([photoDictionary[FLICKR_PHOTO_TITLE] length]) {
            photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.unique = unique;
            photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
            photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
            photo.latitude = [[photoDictionary valueForKeyPath:FLICKR_LATITUDE] doubleValue];
            photo.longitude = [[photoDictionary valueForKeyPath:FLICKR_LONGITUDE] doubleValue];
            photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
            photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
            
            NSString *photographer = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
            photo.whoTook = [Photographer photographerWithName:photographer inManagedObjectContext:context];
        }
    }
    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context{
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}

@end
