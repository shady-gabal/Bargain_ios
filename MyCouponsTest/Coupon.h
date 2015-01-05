//
//  Coupon.h
//  MyCouponsTest
//
//  Created by Shady Gabal on 11/24/14.
//  Copyright (c) 2014 Shady Gabal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Coupon : NSObject

@property (nonatomic) UIView * couponImageView;
@property (nonatomic) UIView * couponReadMoreView;
@property (nonatomic) UIImage * couponImage;
@property (nonatomic) NSString * title;
@property (nonatomic, assign) BOOL selected;


-(instancetype) init;
-(instancetype) initWithImageNamed:(NSString *) imageName;
-(instancetype) initWithTemplateNum:(int) templateNum;
@end
