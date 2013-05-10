//
//  FSProNearDetailCell.m
//  FashionShop
//
//  Created by gong yi on 12/11/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProNearDetailCell.h"

@implementation FSProNearDetailCell

-(void)setTitle:(NSString *)_title subTitle:(NSString *)_subTitle dateString:(NSString*)_dateString
{
    int yCap = 12;
    _cellHeight = yCap;
    
    [_lblTitle setText:_title];
    CGRect _rect = _lblTitle.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _lblTitle.frame.size.height;
    _lblTitle.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    [_lblSubTitle setText:_subTitle];
    //[_lblSubTitle sizeToFit];
    _rect = _lblSubTitle.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _lblSubTitle.frame.size.height;
    _lblSubTitle.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    [_timeView setTextAlignment:RTTextAlignmentCenter];
    [_timeView setText:_dateString];
    _rect = _timeView.frame;
    _rect.origin.y = (_cellHeight - _timeView.optimumSize.height)/2;
    _rect.size.height = _timeView.optimumSize.height;
    _timeView.frame = _rect;
    
    _rect = _line.frame;
    _rect.origin.y = yCap;
    _rect.size.height = _cellHeight - yCap*2;
    _line.frame = _rect;
    
    _rect = _line2.frame;
    _rect.origin.y = _cellHeight - 1;
    _line2.frame = _rect;
    [self bringSubviewToFront:_line2];
}

@end

@implementation FSProDateDetailCell

-(void)setTitle:(NSString *)_title desc:(NSString *)_desc address:(NSString*)aAddress dateString:(NSString*)_dateString
{
    int yCap = 8;
    _cellHeight = yCap;
    
    [_titleView setText:_title];
    CGRect _rect = _titleView.frame;
    _rect.origin.y = _cellHeight;
    _rect.size.height = _titleView.frame.size.height;
    _titleView.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    [_descView setText:_desc];
    _rect = _descView.frame;
    [_descView sizeToFit];
    _rect.origin.y = _cellHeight;
    _rect.size.height = _descView.frame.size.height;
    _descView.frame = _rect;
    _cellHeight += _rect.size.height + yCap;
    
    _rect = _addressIcon.frame;
    _rect.origin.y = _cellHeight;
    _rect.origin.x = _descView.frame.origin.x;
    _addressIcon.frame = _rect;
    
    [_address setText:aAddress];
    [_address sizeToFit];
    _rect = _address.frame;
    _rect.origin.y = _cellHeight + (_addressIcon.frame.size.height - _address.frame.size.height)/2;
    _rect.origin.x = _addressIcon.frame.origin.x + _addressIcon.frame.size.width + 5;
    _rect.size.height = _address.frame.size.height;
    _address.frame = _rect;
    _cellHeight += (_address.frame.size.height>_addressIcon.frame.size.height?_address.frame.size.height:_addressIcon.frame.size.height) + yCap;
    
    [_timeView setTextAlignment:RTTextAlignmentCenter];
    [_timeView setText:_dateString];
    _rect = _timeView.frame;
    _rect.origin.y = (_cellHeight - _timeView.optimumSize.height)/2;
    _rect.size.height = _timeView.optimumSize.height;
    _timeView.frame = _rect;
    
    _rect = _line.frame;
    _rect.origin.y = yCap;
    _rect.size.height = _cellHeight - yCap*2;
    _line.frame = _rect;
    
    _rect = _line2.frame;
    _rect.origin.y = _cellHeight - 1;
    _line2.frame = _rect;
    [self bringSubviewToFront:_line2];
}

@end
