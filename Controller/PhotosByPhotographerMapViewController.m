//
//  PhotosByPhotographerMapViewController.m
//  Photomania
//
//  Created by 刘江 on 2017/4/7.
//  Copyright © 2017年 Flicker. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "PhotosByPhotographerMapViewController.h"
#import "Photographer+CoreDataClass.h"
#import "Photographer+Create.h"
#import "Photo+CoreDataClass.h"
#import "AddPhotoViewController.h"
#import "ImageViewController.h"
#import "Photo+Annotation.h"

@interface PhotosByPhotographerMapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@property (strong,nonatomic) NSArray *photosByPhotographer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPhotoBarButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) CLLocation *userLocation;

@end

@implementation PhotosByPhotographerMapViewController

#pragma mark - Lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark - Self Location

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    // only set user location and make it center of map when take my photos
    if (self.photographer.isUser) {
        self.userLocation = userLocation.location;
        [self.mapView setCenterCoordinate:userLocation.coordinate];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    self.mapView.showsUserLocation = YES;
}

#pragma mark - Properties

- (CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (NSArray *)photosByPhotographer{
    if (!_photosByPhotographer) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@",self.photographer];
        _photosByPhotographer = [self.photographer.managedObjectContext executeFetchRequest:request error:NULL];
    }
    return _photosByPhotographer;
}

- (void)setPhotographer:(Photographer *)photographer{
    _photographer = photographer;
    self.title = photographer.name;
    self.photosByPhotographer = nil;
    [self updateMapViewAnnotations];
    [self updateAddPhotoBarButtonItem];
}

- (void)setMapView:(MKMapView *)mapView{
    _mapView = mapView;
    _mapView.delegate = self;
    [self updateMapViewAnnotations];
}

#pragma mark - Update UI

- (void)updateMapViewAnnotations{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.photosByPhotographer];
    [self.mapView showAnnotations:self.photosByPhotographer animated:YES];
}

- (void)updateAddPhotoBarButtonItem{
    if (self.addPhotoBarButton) {
        BOOL canAddPhoto = self.photographer.isUser;
        NSMutableArray *rightBarButtonItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (!rightBarButtonItems) {
            rightBarButtonItems = [[NSMutableArray alloc] init];
        }
        NSUInteger addPhotoButtonIndex = [rightBarButtonItems indexOfObject:self.addPhotoBarButton];
        if (addPhotoButtonIndex == NSNotFound) {
            if(canAddPhoto) [rightBarButtonItems addObject:self.addPhotoBarButton];
        } else {
            if(!canAddPhoto) [rightBarButtonItems removeObjectAtIndex:addPhotoButtonIndex];
        }
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *reuseid = @"PhotosByPhotographerMapViewController";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseid];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseid];
        view.canShowCallout = YES;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        view.leftCalloutAccessoryView = imageView;
        UIButton *disclosureButton = [[UIButton alloc] init];
        [disclosureButton setBackgroundImage:[UIImage imageNamed:@"disclosure"] forState:UIControlStateNormal];
        [disclosureButton sizeToFit];
        view.rightCalloutAccessoryView = disclosureButton;
    }
    view.annotation = annotation;
    
    return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)annotationView{
    UIImageView *imageView = nil;
    if ([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        imageView = (UIImageView *)annotationView.leftCalloutAccessoryView;
    }
    if (imageView) {
        Photo *photo = nil;
        if ([annotationView.annotation isKindOfClass:[Photo class]]) {
            photo = (Photo *)annotationView.annotation;
        }
        if (photo) {
            dispatch_queue_t queue = dispatch_queue_create("Fetch Thumbnail", NULL);
            dispatch_async(queue, ^{
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
                UIImage *thumbnailImage = [UIImage imageWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = thumbnailImage;
                });
            });
        }
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    [self performSegueWithIdentifier:@"Show Photo" sender:view];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[AddPhotoViewController class]]) {
        AddPhotoViewController *pvc = (AddPhotoViewController *)(segue.destinationViewController);
        pvc.photographer = self.photographer;
        pvc.userlocation = self.userLocation;
    } else if([sender isKindOfClass:[MKAnnotationView class]]) {
        ImageViewController *ivc = (ImageViewController *)(segue.destinationViewController);
        MKAnnotationView *annotationView = (MKAnnotationView *)sender;
        Photo *photo = (Photo *)(annotationView.annotation);
        ivc.imageURL = [NSURL URLWithString:photo.imageURL];
        ivc.title = photo.title;
    }
}

- (IBAction)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC{
    if ([unwindSegue.sourceViewController isKindOfClass:[AddPhotoViewController class]]) {
        AddPhotoViewController *apvc = (AddPhotoViewController *)(unwindSegue.sourceViewController);
        Photo *addedPhoto = apvc.addedPhoto;
        if (addedPhoto) {
            [self.mapView addAnnotation:addedPhoto];
            [self.mapView showAnnotations:self.mapView.annotations animated:YES];
            self.photosByPhotographer = nil;
        } else {
            NSLog(@"AddPhotoViewController unexpectedly did not add a photo!");
        }
        
    }
}




@end
