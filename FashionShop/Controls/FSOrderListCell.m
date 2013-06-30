//
//  FSOrderListCell.m
//  FashionShop
//
//  Created by HeQingshan on 13-6-22.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSOrderListCell.h"
#import "UIImageView+WebCache.h"

@implementation FSOrderListCell

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

-(void) setData:(FSOrderInfo *)data
{
    _data = data;
    
    FSResource *defaultRes = _data.resource;
    [_imgPro setImageWithURL:defaultRes.absoluteUrl120];
    _imgPro.contentMode = UIViewContentModeScaleAspectFit;
    
    _priceLb.text = [NSString stringWithFormat:@"￥%.2f", _data.totalamount];
    _priceLb.backgroundColor = [UIColor clearColor];
    
    _orderNumber.text = [NSString stringWithFormat:@"预订单编号：%@", _data.orderno];
    _orderNumber.textColor = [UIColor colorWithHexString:@"#181818"];
    _orderNumber.font = [UIFont systemFontOfSize:15];
    _orderNumber.adjustsFontSizeToFitWidth = YES;
    _orderNumber.minimumFontSize = 12;
    
    _crateDate.text = [NSString stringWithFormat:@"创建时间：%@", _data.createdate];
    _crateDate.textColor = [UIColor colorWithHexString:@"#181818"];
    _crateDate.font = [UIFont systemFontOfSize:15];
    _crateDate.adjustsFontSizeToFitWidth = YES;
    _crateDate.minimumFontSize = 12;
}

@end
