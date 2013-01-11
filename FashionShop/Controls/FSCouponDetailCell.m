//
//  FSCouponDetailCell.m
//  FashionShop
//
//  Created by gong yi on 11/28/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSCouponDetailCell.h"
#import "UIImageView+WebCache.h"
#import "UITableViewCell+BG.h"

@implementation FSCouponDetailCell
@synthesize data=_data;

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
-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIView *bg = [[UIView alloc] initWithFrame:self.frame];
        bg.backgroundColor =[UIColor grayColor];
        self.selectedBackgroundView =bg;
    }
    return self;
}


-(void) setData:(FSCoupon *)data
{
    _data = data;
    FSResource *defaultRes = [_data.product.resource lastObject];
    [_imgPro setImageWithURL:defaultRes.absoluteUrl120];
    _lblCode.text = _data.code;
    _lblCode.font = ME_FONT(14);
    _lblCode.textColor = [UIColor whiteColor];
    [_lblCode sizeToFit];
    _lblCode.backgroundColor = [UIColor grayColor];
    _lblTitle.text = _data.productname;
    _lblTitle.textColor = [UIColor colorWithRed:0 green:0 blue:0];
    _lblTitle.font = [UIFont systemFontOfSize:14];
    _lblTitle.numberOfLines = 0;
    _lblTitle.lineBreakMode = NSLineBreakByCharWrapping;
    _lblTitle.adjustsFontSizeToFitWidth = YES;
    _lblTitle.minimumFontSize = 12;
    _lblStore.text = [NSString stringWithFormat:NSLocalizedString(@"User_Coupon_store%a", nil),_data.product.store.name];
    _lblStore.font = ME_FONT(12);
    _lblStore.textColor = [UIColor colorWithRed:102 green:102 blue:102];
    [_lblStore sizeToFit];
    NSString *dateString =@"";
    if ([_data isUsed])
    {
        dateString = NSLocalizedString(@"coupon used", nil);
    } else if ([_data isExpired])
    {
        dateString = NSLocalizedString(@"coupon expired", nil);
    } else
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        dateString = [NSString stringWithFormat:NSLocalizedString(@"coupon will expired:%@", nil),[df stringFromDate:_data.endDate]];
    }
    _lblDuration.text = dateString;
    _lblDuration.font =ME_FONT(10);
    _lblDuration.textColor = [UIColor colorWithRed:153 green:153 blue:153];
    [_lblDuration sizeToFit];

 
}


@end
