//
//  FSProDetailView.m
//  FashionShop
//
//  Created by gong yi on 12/4/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProDetailView.h"
#import "UIImageView+WebCache.h"


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
    _lblDescrip.text = _data.descrip;
    _lblDescrip.font = ME_FONT(12);
    _lblDescrip.textColor = [UIColor colorWithRed:102 green:102 blue:102];
    _lblDescrip.numberOfLines = 2;
    CGRect origFrame = _lblDescrip.frame;
    CGSize fitSize = [_lblDescrip sizeThatFits:_lblDescrip.frame.size];
    origFrame.size.height = fitSize.height;
    origFrame.size.width = fitSize.width;
    _lblDescrip.frame = origFrame;

    FSResource *imgObj = [_data.resource lastObject];
    if (imgObj)
    {
        CGSize cropSize = CGSizeMake(self.frame.size.width, 400 );
        [_imgView setImageUrl:imgObj.absoluteUrl320 resizeWidth:cropSize];
    }
    
    _lblStoreAddress.text = [NSString stringWithFormat:@"%@ \(%d公里)",_data.store.name,(int)_data.store.distance/1000];
    _lblStoreAddress.font = ME_FONT(14);
    _lblStoreAddress.textColor = [UIColor colorWithRed:229 green:0 blue:79];
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
   
    originContent.height = origiFrame.size.height +self.imgView.frame.size.height +_lblStoreAddress.superview.frame.size.height+ 10+PRO_DETAIL_COMMENT_INPUT_HEIGHT;
    originContent.width = MAX(originContent.width, self.frame.size.width);
    self.svContent.contentSize = originContent;

}

-(void) willRemoveFromSuper
{
    _imgView.image = nil;
    _data = nil;
}

@end
