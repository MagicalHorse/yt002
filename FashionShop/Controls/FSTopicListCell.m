//
//  FSTopicListCell.m
//  FashionShop
//
//  Created by HeQingshan on 13-1-25.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSTopicListCell.h"

@implementation FSTopicListCell

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

-(void)setData:(FSTopic *)data
{
    _data = data;
    
    if (_data.resources && _data.resources.count>0)
    {
        NSURL *url = [(FSResource *)_data.resources[0] absoluteUrl];
        if (url)
        {
            [_content setImageWithURL:url placeholderImage:nil];
        }
    }
}

@end
