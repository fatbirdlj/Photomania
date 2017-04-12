//
//  PhotomaniaAppDelegate.m
//  Photomania
//
//  Created by 刘江 on 2017/4/10.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "PhotomaniaAppDelegate.h"
#import "PhotomaniaAppDelegate+MOC.h"
#import "FlickrFetcher.h"
#import <CoreData/CoreData.h>
#import "Photo+Flickr.h"
#import "Photo+CoreDataClass.h"
#import "Photographer+Create.h"
#import "PhotoDatabaseAvailability.h"


@interface PhotomaniaAppDelegate()<NSURLSessionDownloadDelegate>

@property (strong,nonatomic) NSManagedObjectContext *photoDatabaseContext;
@property (strong,nonatomic) NSURLSession *flickrDownloadSession;
@property (copy,nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (strong,nonatomic) NSTimer *flickrForegroundFetchTimer;

@end

#define FLICKR_FETCH @"Fetch Recent Photos From Flickr"
#define FOREGROUD_FLICKR_FETCH_INTERNAL (20*60)
#define BACKGROUND_FETCH_TIMEOUT (10)



@implementation PhotomaniaAppDelegate

#pragma mark - Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    self.photoDatabaseContext = [self createMainQueueManagedObjectContext];
    [self startFlickrFetch];
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if (self.photoDatabaseContext) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = BACKGROUND_FETCH_TIMEOUT;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [NSURLRequest requestWithURL:[FlickrFetcher URLForRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Flickr backgroud fetch failed: %@",error.localizedDescription);
                completionHandler(UIBackgroundFetchResultNoData);
            } else {
                [self loadFlickrPhotoFromLocalURL:location
                                      intoContext:self.photoDatabaseContext
                              andThenExecuteBlock:^{
                                  completionHandler(UIBackgroundFetchResultNewData);
                              }];
            }
        }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Flickr Fetch

- (void)startFlickrFetch{
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLForRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [task resume];
            }
        }
    }];
}

- (void)startFlickrFetch:(NSTimer *)timer{
    [self startFlickrFetch];
}

- (void)loadFlickrPhotoFromLocalURL:(NSURL *)localFile
                        intoContext:(NSManagedObjectContext *)context
                andThenExecuteBlock:(void(^)())whenDone{
    if (context) {
        NSArray *photos = [self flickrPhotosAtURL:localFile];
        [context performBlock:^{
            [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
            [context save:NULL];
            if(whenDone) whenDone();
        }];
    } else {
        if(whenDone) whenDone();
    }
}

- (NSArray *)flickrPhotosAtURL:(NSURL *)url{
    NSDictionary *propertyList;
    NSData *flickrJSONdata = [NSData dataWithContentsOfURL:url];
    if (flickrJSONdata) {
        propertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONdata options:0 error:NULL];
    }
    return [propertyList valueForKeyPath:FLICKR_PHOTO_PATH];
}

#pragma mark - Properties

- (NSURLSession *)flickrDownloadSession{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken,^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_FETCH];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:nil];
        });
    }
    
    return _flickrDownloadSession;
}

- (void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext{
    _photoDatabaseContext = photoDatabaseContext;
    
    if (photoDatabaseContext) [Photographer userInManagedObjectContext:photoDatabaseContext];
    
    [self.flickrForegroundFetchTimer invalidate];
    self.flickrForegroundFetchTimer = nil;
    
    if (photoDatabaseContext) {
        self.flickrForegroundFetchTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUD_FLICKR_FETCH_INTERNAL target:self selector:@selector(startFlickrFetch:) userInfo:nil repeats:YES];
    }
    
    NSDictionary *userInfo = photoDatabaseContext ? @{ PhotoDatabaseAvailabilityContext : photoDatabaseContext} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification object:self userInfo:userInfo];
}


#pragma mark - NSURLSessionDownloadDeleagate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        [self loadFlickrPhotoFromLocalURL:location intoContext:self.photoDatabaseContext andThenExecuteBlock:^{
            [self flickrDownloadTaskMightBeComplete];
        }];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error && session == self.flickrDownloadSession) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
        [self flickrDownloadTaskMightBeComplete];
    }
}

- (void)flickrDownloadTaskMightBeComplete{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            if (![downloadTasks count]) {
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}

@end
