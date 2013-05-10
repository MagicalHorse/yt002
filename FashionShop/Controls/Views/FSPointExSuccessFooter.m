//
//  FSPointView.m
//  FashionShop
//
//  Created by HeQingshan on 13-5-2.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSPointExSuccessFooter.h"

//礼券兑换成功Cell之footer
@implementation FSPointExSuccessFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)initView:(FSExchangeSuccess*)data
{
    int yCap = 12;
    int _cellHeight = _infomationDesc.frame.origin.y;
    NSString *str = [NSString stringWithFormat:@"<font face='%@' size=13>注意事项 : \n</font>%@<font face='%@' size=13 color='#666666'></font>", Font_Name_Normal,data.exclude,Font_Name_Normal];
    [_infomationDesc setText:str];
    CGRect _rect = _infomationDesc.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _infomationDesc.optimumSize.height;
    _infomationDesc.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    _rect = self.frame;
    _rect.size.height = _cellHeight;
    self.frame = _rect;
}

@end
