//
//  ImageViewController.m
//  Photomania
//
//  Created by 刘江 on 2017/4/7.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "ImageViewController.h"
#import "URLViewController.h"

@interface ImageViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UIImage *image;
@end

@implementation ImageViewController

#pragma mark - Lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

#pragma mark - Properties

- (void)setImageURL:(NSURL *)imageURL{
    _imageURL = imageURL;
    [self startFetchImage];
}

- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
    [self.imageView sizeToFit];
    
    self.scrollView.contentSize = image ? image.size : CGSizeZero;
    [self.spinner stopAnimating];
}

- (UIImage *)image{
    return self.imageView.image;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}


- (void)setScrollView:(UIScrollView *)scrollView{
    _scrollView = scrollView;
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

#pragma mark - Fetch Image

- (void)startFetchImage{
    
    self.image = nil;
    
    if (self.imageURL) {
        [self.spinner startAnimating];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                if ([request.URL isEqual:self.imageURL]) {
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image = image;
                    });
                }
            }
        }];
        [task resume];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (self.imageURL && [segue.destinationViewController isKindOfClass:[URLViewController class]]) {
        URLViewController *vc = (URLViewController *)(segue.destinationViewController);
        vc.url = self.imageURL;
    }
}

@end
