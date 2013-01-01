//
//  FSPointDetailCell.m
//  FashionShop
//
//  Created by gong yi on 11/28/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSPointDetailCell.h"
#import "UITableViewCell+BG.h"

@implementation FSPointDetailCell

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
        [self setBackgroundViewUniveral];
    }
    return self;
}

-(void)setData:(FSPoint *)data
{
    if (_data==data) {
        return;
    }
    _data = data;
    _lblReason.text = [NSString stringWithFormat:NSLocalizedString(@"%@ got:%dpoints",nil),_data.getReason,_data.amount];
    _lblReason.font = ME_FONT(14);
    _lblReason.textColor = [UIColor colorWithRed:51 green:51 blue:51];
    CGSize newSize = [_lblReason.text sizeWithFont:ME_FONT(14) constrainedToSize:CGSizeMake(200, 100) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect origFrame = _lblReason.frame;
    origFrame.size.width = newSize.width;
    origFrame.size.height = newSize.height;
    _lblReason.frame = origFrame;
    _lblReason.numberOfLines = 0;
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy.MM.dd"];
    _lblInDate.text = [NSString stringWithFormat:@"%@",[formater stringFromDate:_data.inDate]];
    _lblInDate.font = ME_FONT(9);
    _lblInDate.textColor = [UIColor colorWithRed:102 green:102 blue:102];
    _lblInDate.textAlignment = NSTextAlignmentRight;
    
}

@end
