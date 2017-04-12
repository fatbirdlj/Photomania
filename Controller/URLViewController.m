//
//  URLViewController.m
//  Photomania
//
//  Created by 刘江 on 2017/4/7.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "URLViewController.h"

@interface URLViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation URLViewController

- (void)setUrl:(NSURL *)url{
    _url = url;
    self.textView.text = [url absoluteString];
}

- (void)viewDidLoad{
    self.textView.text = [self.url absoluteString];
}

@end
