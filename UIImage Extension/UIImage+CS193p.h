//
//  UIImage+CS193p.h
//  Photomania
//
//  Created by 刘江 on 2017/4/10.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CS193p)

- (UIImage *)imageByScalingToSize:(CGSize)size;

- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName;

@end
