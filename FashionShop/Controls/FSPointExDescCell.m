//
//  FSPointExDescCell.m
//  FashionShop
//
//  Created by HeQingshan on 13-5-2.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSPointExDescCell.h"

@implementation FSPointExDescCell

-(void)setData:(id)data
{
    _data = data;
    int yCap = 12;
    _cellHeight = yCap;
    
    //title
    NSString *str = @"<font face='HelveticaNeue-CondensedBold' size=16>活动描述</font>";
    [_titleView setText:str];
    CGRect _rect = _titleView.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _titleView.optimumSize.height;
    _titleView.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    //line1
    _rect = _line1.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = 1;
    _line1.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    //活动时间
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yy年MM月dd日"];
    str = [NSString stringWithFormat:@"<font face='%@' size=13 color='#666666'>活动时间 : %@ 至 %@</font>", Font_Name_Normal, [df stringFromDate:_data.activeStartDate], [df stringFromDate:_data.activeEndDate]];
    [_activityTime setText:str];
    _activityTime.textColor = RGBCOLOR(107, 107, 107);
    _rect = _activityTime.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _activityTime.optimumSize.height;
    _activityTime.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    //使用有效期
    str = [NSString stringWithFormat:@"<font face='%@' size=13 color='#666666'>使用有效期 : %@止</font>", Font_Name_Normal, [df stringFromDate:_data.couponEndDate]];
    [_useTime setText:str];
    _rect = _useTime.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _useTime.optimumSize.height;
    _useTime.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    //参与门店
    NSMutableString *storeDesc = [NSMutableString string];
    for (int i = 0; i < _data.inscopenotices.count; i++) {
        FSCommon *com = _data.inscopenotices[i];
        if (i != _data.inscopenotices.count - 1) {
            [storeDesc appendFormat:@"%@,", com.storename];
        }
        else{
            [storeDesc appendFormat:@"%@", com.storename];
        }
    }
    str = [NSString stringWithFormat:@"<font face='%@' size=13 color='#666666'>参与门店 : %@</font>", Font_Name_Normal, storeDesc];
    [_joinStore setText:str];
    _rect = _joinStore.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _joinStore.optimumSize.height;
    _joinStore.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    //礼券使用范围
    str = [NSString stringWithFormat:@"<font face='%@' size=13 color='#666666'>礼券使用范围  </font><font face='%@' size=13 color='0092f8'><a href=''>点击查看</a></font>", Font_Name_Normal, Font_Name_Normal];
    [_useScope setText:str];
    _rect = _useScope.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _useScope.optimumSize.height;
    _useScope.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    //line2
    _rect = _line2.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = 1;
    _line2.frame = _rect;
    _cellHeight += _rect.size.height;
}

@end

@implementation FSPointExDoCell

-(void)setData:(id)data
{
    _data = data;
    [_exBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
    [_exBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_sel.png"] forState:UIControlStateHighlighted];
    _pointTipLb.text = [NSString stringWithFormat:@"起兑积点:%d", _data.minPoints];
    _unitPerPoint.text = [NSString stringWithFormat:@"注意：兑换的积点必须是%d的整数倍", _data.unitPerPoints];
}

@end

@implementation FSPointExCommonCell

-(void)setData
{
    int yCap = 12;
    _cellHeight = yCap;
    
    //title
    NSString *str = _title;
    [_titleView setText:str];
    CGRect _rect = _titleView.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _titleView.frame.size.height;
    _titleView.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    //line2
    _rect = _line2.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = 1;
    _line2.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    str = [NSString stringWithFormat:@"<font face='%@' size=13 color='#666666'>%@</font>", Font_Name_Normal, _desc];
    [_content setText:str];
    _rect = _content.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _content.optimumSize.height;
    _content.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
}

@end

@implementation FSPointScopeCell

-(void)setData:(id)data
{
    _data = data;
    int yCap = 12;
    _cellHeight = yCap;
    
    //title
    NSString *str = [NSString stringWithFormat:@"<font face='%@' size=13>使用门店 : </font><font face='%@' size=13 color='00ff00'>%@</font>", Font_Name_Normal, Font_Name_Normal, _data.storename];
    [_storeName setText:str];
    CGRect _rect = _storeName.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _storeName.optimumSize.height;
    _storeName.frame = _rect;
    _cellHeight += _rect.size.height + yCap - 4;
    
    str = [NSString stringWithFormat:@"<font face='%@' size=13>使用范围 : </font><font face='%@' size=13 color='00ff00'>%@</font>", Font_Name_Normal,Font_Name_Normal,_data.excludes];
    [_useScope setText:str];
    _rect = _useScope.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _useScope.optimumSize.height;
    _useScope.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
}

@end

//礼券兑换成功Cell
@implementation FSPointExSuccessCell

-(void)setData:(id)data
{
    _data = data;
    _giftNumber.text = _data.giftCode;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yy年MM月dd日 HH:MM:SS"];
    _exTime.text = [NSString stringWithFormat:@"%@", [df stringFromDate:_data.createDate]];
    [df setDateFormat:@"yy年MM月dd日"];
    _stopTime.text = [NSString stringWithFormat:@"%@止", [df stringFromDate:_data.validEndDate]];
    _storeName.text = _data.storeName;
    _pointCount.text = [NSString stringWithFormat:@"%d", _data.points];
    _moneyCount.text = [NSString stringWithFormat:@"%.2f元", _data.amount];
    [_moneyCount setTextColor:[UIColor redColor]];
}

@end