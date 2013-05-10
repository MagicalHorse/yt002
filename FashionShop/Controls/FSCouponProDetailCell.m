//
//  FSCouponProDetailCell.m
//  FashionShop
//
//  Created by gong yi on 12/31/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSCouponProDetailCell.h"
#import "UITableViewCell+BG.h"

@implementation FSCouponProDetailCell

-(void) setData:(FSCoupon *)data
{
    _data = data;
    int yCap = 8;
    _cellHeight = yCap;
    
    //标题
    _lblTitle.text = _data.productname;
    _lblTitle.adjustsFontSizeToFitWidth = YES;
    _lblTitle.minimumFontSize = 12;
    CGRect _rect = _lblTitle.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _lblTitle.frame.size.height;
    _lblTitle.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    //有效期
    NSString *dateString =@"";
    if ([_data isUsed])
    {
        dateString = NSLocalizedString(@"coupon used", nil);
    } else if([_data isExpired])
    {
        dateString = NSLocalizedString(@"coupon expired", nil);
    } else
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        dateString = [NSString stringWithFormat:NSLocalizedString(@"coupon will expired:%@", nil),[df stringFromDate:_data.endDate]];
    }
    _lblDuration.text = dateString;
    _lblDuration.font =ME_FONT(13);
    _lblDuration.textColor = [UIColor colorWithRed:153 green:153 blue:153];
    [_lblDuration sizeToFit];
    _rect = _lblDuration.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _lblDuration.frame.size.height;
    _lblDuration.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    //实体店名称
    _lblStore.text = [NSString stringWithFormat:NSLocalizedString(@"User_Coupon_store%a", nil),_data.promotion.store.name];
    _lblStore.font = ME_FONT(13);
    _lblStore.textColor = [UIColor colorWithRed:102 green:102 blue:102];
    [_lblStore sizeToFit];
    _rect = _lblStore.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _lblStore.frame.size.height;
    _lblStore.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    //优惠码
    _lblCode.text = _data.code;
    _lblCode.font = BFONT(18);
    _lblCode.textColor = [UIColor greenColor];
    _rect = _lblCode.frame;
    _rect.origin.y = (_cellHeight - _lblDuration.frame.size.height)/2;
    _rect.size.height = _lblCode.frame.size.height;
    _lblCode.frame = _rect;
}


@end
