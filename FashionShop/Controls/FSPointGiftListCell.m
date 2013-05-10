//
//  FSPointGiftListCell.m
//  FashionShop
//
//  Created by HeQingshan on 13-5-2.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSPointGiftListCell.h"

@implementation FSPointGiftListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(id)data
{
    _data = data;
    int yCap = 12;
    _cellHeight = yCap;
    
    NSString *str = @"<font face='HelveticaNeue-CondensedBold' size=16>VIP回馈“礼”积点领 VIP回馈“礼”积点领 VIP回馈“礼”积点领 VIP回馈“礼”积点领 VIP回馈“礼”积点领 VIP回馈“礼”积点领 VIP回馈“礼”积点领</font>";
    [_titleView setText:str];
    CGRect _rect = _titleView.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _titleView.optimumSize.height;
    _titleView.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    str = @"<font face='HelveticaNeue-CondensedBold' size=13 color='#e4e400'>有效期:  2013-05-30止</font>";
    [_valideTime setText:str];
    _rect = _valideTime.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _valideTime.optimumSize.height;
    _valideTime.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    str = @"<font face='HelveticaNeue-CondensedBold' size=16 color='#e4e400'>礼券面额:  </font><font face=AmericanTypewriter size=16 color='#CC0000'>50元</font>";
    [_amountView setText:str];
    _rect = _amountView.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _amountView.optimumSize.height;
    _amountView.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    _rect = _giftNumber.frame;
    _rect.origin.y = _valideTime.frame.origin.y;
    _giftNumber.frame = _rect;
    [_giftNumber setText:@"<font face='HelveticaNeue-CondensedBold' size=20 color='#00ee00'>14787890087</font>"];
    [_giftNumber setTextAlignment:RTTextAlignmentRight];
}

@end
