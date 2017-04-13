//
//  AddPhotoViewController.h
//  Photomania
//
//  Created by 刘江 on 2017/4/7.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photographer+CoreDataClass.h"
#import <CoreLocation/CoreLocation.h>

@interface AddPhotoViewController : UIViewController

@property (nonatomic,strong) Photographer *photographer;

@property (nonatomic,readonly) Photo *addedPhoto;

@property (strong,nonatomic) CLLocation *userlocation;

@end
