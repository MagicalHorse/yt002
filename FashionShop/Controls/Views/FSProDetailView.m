//
//  FSProDetailView.m
//  FashionShop
//
//  Created by gong yi on 12/4/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProDetailView.h"
#import "UIImageView+WebCache.h"
#import "NSString+Extention.h"


#define PRO_DETAIL_COMMENT_INPUT_TAG 200
#define TOOLBAR_HEIGHT 44
#define PRO_DETAIL_COMMENT_INPUT_HEIGHT 45
#define PRO_DETAIL_COMMENT_CELL_HEIGHT 73
#define PRO_DETAIL_COMMENT_HEADER_HEIGHT 30

@interface FSProDetailView ()
{
    FSProItemEntity *_data;
}

@end

@implementation FSProDetailView
@synthesize data = _data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setData:(id)data
{
    _data = data;
    _lblTitle.text = _data.title;
    _lblTitle.font = ME_FONT(18);
    
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy/MM/dd"];
    [_lblDuration setValue:[NSString stringWithFormat:@"%@-%@",[formater stringFromDate:_data.startDate],[formater stringFromDate:_data.endDate]] forKey:@"text"];
    _lblDuration.font = ME_FONT(12);

    _couponTitle.text = NSLocalizedString(@"coupon", nil);
    _couponTitle.font = ME_FONT(12);
    _couponTitle.textColor = [UIColor blackColor];
  
    [_lblCoupons setValue:[NSString stringWithFormat:@"%d",_data.couponTotal] forKey:@"text"];
    _lblCoupons.font = ME_FONT(12);
    _lblCoupons.textColor = [UIColor colorWithRed:229 green:0 blue:79];
    _likeTitle.text = NSLocalizedString(@"favor", nil);
    _likeTitle.font = ME_FONT(12);
    _likeTitle.textColor = [UIColor blackColor];

    [_lblFavorCount setValue:[NSString stringWithFormat:@"%d",_data.favorTotal] forKey:@"text"];
    _lblFavorCount.font = ME_FONT(12);
    _lblFavorCount.textColor = [UIColor colorWithRed:229 green:0 blue:79];
    _lblDescrip.text = [_data.descrip trimReturnEmptyChar];
    _lblDescrip.font = ME_FONT(12);
    _lblDescrip.textColor = [UIColor colorWithRed:102 green:102 blue:102];
    _lblDescrip.numberOfLines = 0;
    CGRect origFrame = _lblDescrip.frame;
    CGSize fitSize = [_lblDescrip sizeThatFits:_lblDescrip.frame.size];
    int yOff = 4;
    origFrame.size.height = fitSize.height;
    origFrame.size.width = fitSize.width;
    origFrame.origin.y = _imgFansBG.frame.size.height+_imgFansBG.frame.origin.y+yOff;
    _lblDescrip.frame = origFrame;

    FSResource *imgObj = [_data.resource lastObject];
    if (imgObj)
    {
        CGSize cropSize = CGSizeMake(self.frame.size.width, 277 );
        [_imgView setImageUrl:imgObj.absoluteUrl320 resizeWidth:cropSize];
    }
    NSString *distanceString = [NSString stringMetersFromDouble:_data.store.distance];
    if (distanceString.length>0)
    {
        [_btnStore setTitle:[NSString stringWithFormat:@"%@ \(%@)",_data.store.name,distanceString] forState:UIControlStateNormal];
    } else
    {
       [_btnStore setTitle:_data.store.name forState:UIControlStateNormal];  
    }
    [_btnStore setTitleColor:[UIColor colorWithRed:229 green:0 blue:79] forState:UIControlStateNormal];
    _btnStore.titleLabel.font = ME_FONT(14);
    
    CGSize storesize =[_btnStore sizeThatFits:_btnStore.frame.size];
    _btnStore.frame = CGRectMake(_btnStore.frame.origin.x, _lblDescrip.frame.size.height+_lblDescrip.frame.origin.y+yOff, storesize.width, storesize.height);
    if (_data.tagId!=0)
    {
        _btnTag.alpha =1;
        [_btnTag setTitle:NSLocalizedString(@"see  more products", nil) forState:UIControlStateNormal];
        [_btnTag setBackgroundImage:[UIImage imageNamed:@"pro_tag_bg"] forState:UIControlStateNormal];
        [_btnTag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnTag.titleLabel.font = [UIFont systemFontOfSize:12];
        CGSize newsize = CGSizeMake(77, 22);
        _btnTag.frame = CGRectMake(_imgView.frame.size.width+_imgView.frame.origin.x-newsize.width, _imgView.frame.size.height+_imgView.frame.origin.y-newsize.height, newsize.width, newsize.height);

    } else
    {
        _btnTag.alpha = 0;
    }

    CGRect superFrame =   _btnStore.superview.frame;
    superFrame.size.height = _btnStore.frame.size.height +_btnStore.frame.origin.y+yOff;
    _btnStore.superview.frame = superFrame;
    CGRect commentFrame = _tbComment.frame;
    commentFrame.origin.y = superFrame.origin.y+superFrame.size.height+yOff;
    _tbComment.frame = commentFrame;
    [self updateInteraction:_data];

}

-(void)updateInteraction:(id)updatedEntity
{
    _data.isFavored = [(FSProItemEntity *)updatedEntity isFavored];
    _data.isCouponed = [(FSProItemEntity *)updatedEntity isCouponed];
    
    NSString *favorIcon = _data.isFavored?@"bottom_nav_like_icon.png":@"bottom_nav_like_icon.png";
    NSString *couponIcon = _data.isCouponed?@"bottom_nav_promo-code_icon.png":@"bottom_nav_promo-code_icon.png";
    _btnCoupon.image = [UIImage imageNamed:couponIcon];
    _btnFavor.image = [UIImage imageNamed:favorIcon];
    
}

-(void) resetScrollViewSize
{
    UITableView *table = self.tbComment;
    CGRect origiFrame = table.frame;
    origiFrame.size.height = PRO_DETAIL_COMMENT_CELL_HEIGHT * _data.comments.count+PRO_DETAIL_COMMENT_HEADER_HEIGHT + PRO_DETAIL_COMMENT_CELL_HEIGHT;
    [table setFrame:origiFrame];
    
    
    CGSize originContent = self.svContent.contentSize;
   
    originContent.height = origiFrame.size.height +self.imgView.frame.size.height +_btnStore.superview.frame.size.height+ 10;//+PRO_DETAIL_COMMENT_INPUT_HEIGHT;
    originContent.width = MAX(originContent.width, self.frame.size.width);
    self.svContent.contentSize = originContent;

}

-(void) willRemoveFromSuper
{
    _imgView.image = nil;
    _data = nil;
}

@end
