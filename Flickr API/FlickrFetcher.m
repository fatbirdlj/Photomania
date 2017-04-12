//
//  FlickrFetcher.m
//  Shutterbug
//
//  Created by 刘江 on 2017/4/5.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "FlickrFetcher.h"
#import "FlickrAPIKey.h"

@implementation FlickrFetcher

+ (NSURL *)URLForQuery:(NSString *)query{
    query = [NSString stringWithFormat:@"%@&format=json&nojsoncallback=1&api_key=%s",query,FlickrAPIKey];
    query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [NSURL URLWithString:query];
    
}

+ (NSURL *)URLForRecentGeoreferencedPhotos{
    return [self URLForQuery:[NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&license=1,2,4,7&has_geo=1&extras=original_format,description,geo,date_upload,owner_name"]];
}

+ (NSString *)urlStringForPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format
{
    id farm = [photo objectForKey:@"farm"];
    id server = [photo objectForKey:@"server"];
    id photo_id = [photo objectForKey:@"id"];
    id secret = [photo objectForKey:@"secret"];
    if (format == FlickrPhotoFormatOriginal) secret = [photo objectForKey:@"originalsecret"];
    
    NSString *fileType = @"jpg";
    if (format == FlickrPhotoFormatOriginal) fileType = [photo objectForKey:@"originalformat"];
    
    if (!farm || !server || !photo_id || !secret) return nil;
    
    NSString *formatString = @"s";
    switch (format) {
        case FlickrPhotoFormatSquare:    formatString = @"s"; break;
        case FlickrPhotoFormatLarge:     formatString = @"b"; break;
        case FlickrPhotoFormatOriginal:  formatString = @"o"; break;
    }
    
    return [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@_%@.%@", farm, server, photo_id, secret, formatString, fileType];
}

+ (NSURL *)URLforPhoto:(NSDictionary *)photo format:(FlickrPhotoFormat)format{
    return [NSURL URLWithString:[self urlStringForPhoto:photo format:format]];
}





@end
