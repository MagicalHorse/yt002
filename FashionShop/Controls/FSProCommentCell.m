//
//  FSProCommentCell.m
//  FashionShop
//
//  Created by gong yi on 12/9/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProCommentCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Locale.h"
#import "NSString+Extention.h"
#import "FSConfiguration.h"

@implementation FSProCommentCell
@synthesize data = _data;

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

-(void)setData:(FSComment *)data{
    _data = data;
    _lblNickie.text = [NSString stringWithFormat:@"%@:",_data.inUser.nickie];
    _lblNickie.font = ME_FONT(14);
    _lblNickie.textColor = [UIColor colorWithRed:229 green:0 blue:79];
    [_lblNickie sizeToFit];

    _imgThumb.ownerUser = _data.inUser;

    _lblComment.text = _data.comment;
    _lblComment.font = ME_FONT(12);
    _lblComment.textColor = [UIColor colorWithRed:102 green:102 blue:102];
    _lblComment.numberOfLines = 0;
    CGSize newSize = [_lblComment sizeThatFits:_lblComment.frame.size];
    _lblComment.frame = CGRectMake(_lblComment.frame.origin.x,_lblComment.frame.origin.y,newSize.width,newSize.height);
    _lblInDate.text = [_data.indate toLocalizedString];
    _lblInDate.font = ME_FONT(10);
    _lblInDate.textColor = [UIColor colorWithRed:153 green:153 blue:153];
    
}

@end
