//
//  Photo+Annotation.m
//  Photomania
//
//  Created by 刘江 on 2017/4/9.
//  Copyright © 2017年 Flicker. All rights reserved.
//

#import "Photo+Annotation.h"

@implementation Photo (Annotation)

- (CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.latitude;
    coordinate.longitude = self.longitude;
    return coordinate;
}

@end
