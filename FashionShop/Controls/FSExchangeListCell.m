//
//  FSExchangeListCell.m
//  FashionShop
//
//  Created by HeQingshan on 13-4-28.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSExchangeListCell.h"
#import "FSConfiguration+Fonts.h"

@interface FSExchangeListCell ()

@end

@implementation FSExchangeListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
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
    
    [_titleView setText:_data.name];
    
    [_desc setText:_data.desc];
    _desc.textColor = RGBCOLOR(102, 102, 102);
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yy年MM月dd日"];
    NSString *str = [NSString stringWithFormat:@"%@~%@", [df stringFromDate:_data.activeStartDate], [df stringFromDate:_data.activeEndDate]];
    _activityTime.text = str;
    _activityTime.textColor = RGBCOLOR(228, 0, 127);
}

@end
