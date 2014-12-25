//
//  Coupon.m
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/24/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import "Coupon.h"

static float COUPON_READ_MORE_HEIGHT = 200.f;
static float COUPON_READ_MORE_WIDTH = 80.f;


@implementation Coupon

-(instancetype) init{
    self = [super init];
    if (self){
        self.couponImage = [UIImage imageNamed:@"1.jpg"];
        self.couponImageView = [[UIImageView alloc] initWithImage:self.couponImage];
        self.couponImageView.frame = CGRectMake(0,0, 400, 150);
        self.couponImageView.contentMode = UIViewContentModeScaleToFill;
        self.title = @"Title of coupon";
        self.couponReadMoreView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"banner.jpg"]];
        self.couponReadMoreView.frame = CGRectMake(0,0, COUPON_READ_MORE_WIDTH, COUPON_READ_MORE_HEIGHT);
    }
    return self;
}


-(instancetype) initWithImageNamed:(NSString *) imageName{
    self = [super init];
    if (self){
        self.couponImage = [UIImage imageNamed:imageName];
        self.couponImageView = [[UIImageView alloc] initWithImage:self.couponImage];
        self.couponImageView.frame = CGRectMake(0,0, 400, 150);
        self.couponImageView.contentMode = UIViewContentModeScaleToFill;
        self.title = @"Title of coupon";
        self.couponReadMoreView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"banner.jpg"]];
        self.couponReadMoreView.frame = CGRectMake(0,0, 300, 300);

    }
    return self;
}

@end