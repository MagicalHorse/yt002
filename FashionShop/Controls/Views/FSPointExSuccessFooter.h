//
//  FSPointView.h
//  FashionShop
//
//  Created by HeQingshan on 13-5-2.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"
#import "FSExchange.h"

@interface FSPointExSuccessFooter : UIView

@property (strong, nonatomic) IBOutlet UIButton *continueBtn;
@property (strong, nonatomic) IBOutlet UIButton *backHomeBtn;
@property (strong, nonatomic) IBOutlet RTLabel *infomationDesc;

-(void)initView:(FSExchangeSuccess*)data;

@end
