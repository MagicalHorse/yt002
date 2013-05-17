//
//  FSMyCommentCell.m
//  FashionShop
//
//  Created by HeQingshan on 13-5-14.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSMyCommentCell.h"
#import "NSDate+Locale.h"

#define PRO_DETAIL_COMMENT_CELL_HEIGHT 74

@implementation FSMyCommentCell

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
    _imgThumb.ownerUser = _data.replyUser;
    if (data.resources &&
        data.resources.count > 0 &&
        ((FSResource*)data.resources[0]).type == 2) {
//    if (1) {
        int xOffset = 110;
        _lblComment.text = [NSString stringWithFormat:@"%@: ", _data.replyUser.nickie];
        _lblComment.font = BFONT(13);
        _lblComment.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _lblComment.textColor = [UIColor colorWithRed:102 green:102 blue:102];
        [_lblComment sizeToFit];
        
        if (_lblComment.frame.size.height > 50) {
            CGRect _rect = _lblComment.frame;
            _rect.size.height = 50;
            _lblComment.frame = _rect;
        }
        
        int _width = _lblComment.frame.size.width;
        _lblComment.frame = CGRectMake(_lblComment.frame.origin.x, _lblComment.frame.origin.y, _width>xOffset?xOffset:_width, _lblComment.frame.size.height);
        
        FSResource *_audioResource = [[FSResource alloc] init];//data.resources[0];
        _audioResource.relativePath = @"test";
        _audioResource.width = 51;
        _audioButton = [[FSAudioButton alloc] initWithFrame:CGRectMake(_lblComment.frame.origin.x + (_width>xOffset?xOffset:_width), _lblComment.frame.origin.y - 10, 65, 26)];
        NSMutableString *newPath = [NSMutableString stringWithString:_audioResource.relativePath];
        [newPath replaceOccurrencesOfString:@"\\" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0,newPath.length)];
        _audioButton.fullPath = [NSString stringWithFormat:@"%@%@.mp3", _audioResource.domain,newPath];
        _audioButton.audioTime = [NSString stringWithFormat:@"%d''", (_audioResource.width>0?_audioResource.width:1)];
        [self addSubview:_audioButton];
    }
    else
    {
        _lblComment.text = [NSString stringWithFormat:@"%@: %@", _data.replyUser.nickie, _data.comment];
        _lblComment.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblComment.font = BFONT(13);
        _lblComment.textColor = [UIColor colorWithRed:102 green:102 blue:102];
        _lblComment.numberOfLines = 0;
        CGSize newSize =  [_lblComment sizeThatFits:_lblComment.frame.size];
        _lblComment.frame = CGRectMake(_lblComment.frame.origin.x, 8, 225, newSize.height);
    }
    _cellHeight = _lblComment.frame.origin.y + _lblComment.frame.size.height + 8;
    
    //回复时间
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy年MM月dd日 HH:MM:SS"];
    _lblInDate.text = [df stringFromDate:_data.indate];
    _lblInDate.hidden = NO;
    _lblInDate.frame = CGRectMake(_lblInDate.frame.origin.x, _cellHeight + 8, 225, _lblInDate.frame.size.height);
    _lblInDate.font = ME_FONT(13);
    _lblInDate.textColor = [UIColor colorWithRed:153 green:153 blue:153];
    _cellHeight += _lblInDate.frame.size.height + 8;
    
    //回复人名称
    _lblReplyDesc.frame = CGRectMake(_lblReplyDesc.frame.origin.x, _cellHeight + 5, 225, _lblReplyDesc.frame.size.height);
    _lblReplyDesc.hidden = NO;
    if (![data.replyUserName isEqualToString:@""] && data.replyUserName) {
        _lblReplyDesc.text = [NSString stringWithFormat:@"回复 %@", data.replyUserName];
    }
    else{
        _lblReplyDesc.text = [NSString stringWithFormat:@"评论您参与的%@", _data.sourcetype==1?@"商品":@"活动"];
    }
    _lblReplyDesc.font = ME_FONT(13);
    [_lblReplyDesc sizeThatFits:_lblReplyDesc.frame.size];
    _cellHeight += _lblReplyDesc.frame.size.height;
    
    _cellHeight += 8;
    _cellHeight = MAX(PRO_DETAIL_COMMENT_CELL_HEIGHT, _cellHeight);
}

-(void)updateFrame
{
    int yOffset = 0;
    int height  = [_lblComment sizeThatFits:_lblComment.frame.size].height;
    height += _lblInDate.frame.size.height + 5;
    height += _lblReplyDesc.frame.size.height + 5;
    yOffset = (_cellHeight - height)/2;
    
    CGRect _rect = _lblComment.frame;
    _rect.origin.y = yOffset;
    _lblComment.frame = _rect;
    
    if (_audioButton) {
        _rect = _audioButton.frame;
        _rect.origin.y = _lblComment.frame.origin.y - 7;
        _rect.origin.x = _lblComment.frame.origin.x + _lblComment.frame.size.width + 3;
        _audioButton.frame = _rect;
    }
    
    _rect = _lblInDate.frame;
    _rect.origin.y = _lblComment.frame.size.height + _lblComment.frame.origin.y + 5;
    _lblInDate.frame = _rect;
    
    _rect = _lblReplyDesc.frame;
    _rect.origin.y = _lblInDate.frame.origin.y + _lblInDate.frame.size.height + 5;
    _lblReplyDesc.frame = _rect;
}

@end
