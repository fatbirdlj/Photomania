//
//  AddPhotoViewController.m
//  Photomania
//
//  Created by 刘江 on 2017/4/7.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "AddPhotoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import "UIImage+CS193p.h"
#import "Photo+CoreDataClass.h"



@interface AddPhotoViewController ()<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate>
@property (nonatomic,strong) UIImage *image;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) CLLocation *location;
@property (nonatomic,assign) NSInteger locationErrorCode;
@property (weak, nonatomic) IBOutlet UITextField *titleForPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *subtitleForPhoto;

@property (nonatomic,readwrite) Photo *addedPhoto;

@property (strong,nonatomic) NSURL *imageURL;
@property (strong,nonatomic) NSURL *thumbnailURL;

@end

@implementation AddPhotoViewController

#pragma mark - Properties

- (UIImage *)image{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
    [[NSFileManager defaultManager] removeItemAtURL:_imageURL error:NULL];
    [[NSFileManager defaultManager] removeItemAtURL:_thumbnailURL error:NULL];
    self.imageURL = nil;
    self.thumbnailURL = nil;
}

- (CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

- (NSURL *)imageURL{
    if (!_imageURL && self.image) {
        NSURL *url = [self uniqueDocumentURL];
        if (url) {
            NSData *imageData = UIImageJPEGRepresentation(self.image, 1.0);
            if ([imageData writeToURL:url atomically:YES]) {
                _imageURL = url;
            }
        }
    }
    return _imageURL;
}

- (NSURL *)thumbnailURL{
    NSURL *url = [self.imageURL URLByAppendingPathExtension:@"thumbnail"];
    if (![_thumbnailURL isEqual:url]) {
        _thumbnailURL = nil;
        if (url) {
            UIImage *thumbnail = [self.image imageByScalingToSize:CGSizeMake(75, 75)];
            NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
            if ([imageData writeToURL:url atomically:YES]) {
                _thumbnailURL = url;
            }
        }
    }
    return _thumbnailURL;
}

- (NSURL *)uniqueDocumentURL{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.0f", floor([NSDate timeIntervalSinceReferenceDate])];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}

#pragma mark - Capabilities

+ (BOOL)canAddPhoto{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Target/Action

- (IBAction)cancel:(UIButton *)sender {
    self.image = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhoto:(UIButton *)sender {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    ipc.mediaTypes = @[(NSString *)kUTTypeImage];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (IBAction)filterImage {
    if (!self.image) {
        [self alert:@"Please select a photo first!"];
    } else {
        UIAlertController *aciontSheet = [UIAlertController alertControllerWithTitle:@"Filter Image" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (NSString *filter in [self filters]) {
            UIAlertAction *filterButton = [UIAlertAction actionWithTitle:filter style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSString *filterName = [self filters][filter];
                self.image = [self.image imageByApplyingFilterNamed:filterName];
            }];
            
            [aciontSheet addAction:filterButton];
        }
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [aciontSheet addAction:cancelButton];
        [self presentViewController:aciontSheet animated:YES completion:nil];
    }
    
}

- (NSDictionary *)filters{
    return @{ @"Chrome" : @"CIPhotoEffectChrome",
              @"Blur" : @"CIGaussianBlur",
              @"Noir" : @"CIEffectNori",
              @"Fade" : @"CIEffectFade"
             };
}

#pragma mark - Alerts

- (void)alert:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Photo" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)fatalAlert:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Photo" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action){
        [self cancel:nil];
    }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }
    self.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    self.location = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    self.locationErrorCode = error.code;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"Do Add Photo"]) {
        NSManagedObjectContext *context = self.photographer.managedObjectContext;
        if (context) {
            Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.title = self.titleForPhoto.text;
            photo.subtitle = self.subtitleForPhoto.text;
            photo.whoTook = self.photographer;
            photo.latitude = self.location.coordinate.latitude;
            photo.longitude = self.location.coordinate.longitude;
            photo.imageURL = [self.imageURL absoluteString];
            photo.thumbnailURL = [self.thumbnailURL absoluteString];
            
            [context save:NULL];
            
            self.addedPhoto = photo;
            
            self.imageURL = nil;
            self.thumbnailURL = nil;
        }
        
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqualToString:@"Do Add Photo"]){
        if (!self.image) {
            [self alert:@"No photo taken!"];
            return NO;
        } else if(![self.titleForPhoto.text length]){
            [self alert:@"Title required!"];
            return NO;
        } else if(!self.location){
            switch (self.locationErrorCode) {
                case kCLErrorLocationUnknown:
                    [self alert:@"Couldn't figure out where this photo was taken (yet)."];
                    break;
                case kCLErrorDenied:
                    [self alert:@"Location Services disabled under Privacy in the settings application."];
                    break;
                case kCLErrorNetwork:
                    [self alert:@"Can't figure out where this photo is being taken. Verify your connection to the network."];
                    break;
                default:
                    [self alert:@"Can't figure out where this photo is being taken. sorry"];
                    break;
            }
            return NO;
        } else {
            return YES;
        }
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

#pragma mark - ViewcController Lifecycle

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![[self class] canAddPhoto]) {
        [self fatalAlert:@"Sorry, this device can't add a photo."];
    } else {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
       [self.locationManager startUpdatingLocation];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}


@end
