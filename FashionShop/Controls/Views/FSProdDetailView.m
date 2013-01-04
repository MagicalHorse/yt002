//
//  FSProdDetailView.m
//  FashionShop
//
//  Created by gong yi on 12/14/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProdDetailView.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "FSResource.h"
#import "FSConfiguration.h"
#import "NSString+Extention.h"


#define PRO_DETAIL_COMMENT_INPUT_TAG 200
#define TOOLBAR_HEIGHT 44
#define PRO_DETAIL_COMMENT_INPUT_HEIGHT 45
#define PRO_DETAIL_COMMENT_CELL_HEIGHT 73
#define PRO_DETAIL_COMMENT_HEADER_HEIGHT 30

@interface FSProdDetailView ()
{
    FSProdItemEntity *_data;
}

@end

@implementation FSProdDetailView
@synthesize data = _data;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) prepareForReuse
{
    _imgThumb = nil;
    _data = nil;
    _btnBrand = nil;
}
-(void)setData:(id)data
{
    self.backgroundColor = [UIColor colorWithRed:229 green:229 blue:229];
    _data = data;
    _imgThumb.ownerUser = _data.fromUser;
    _lblNickie.text = _data.fromUser.nickie;
    _lblNickie.font = ME_FONT(18);
    _lblNickie.textColor =[UIColor blackColor];
    [_lblNickie sizeToFit];
    [_btnBrand setTitleColor:[UIColor colorWithRed:51 green:51 blue:51] forState:UIControlStateNormal];
    NSString *brand = [NSString stringWithFormat:@"%@",_data.brand.name];
    [_btnBrand setTitle:brand forState:UIControlStateNormal];
    _btnBrand.titleLabel.font = ME_FONT(15);
    CGSize newSize = [_btnBrand sizeThatFits:_btnBrand.frame.size];
    CGRect origFrame = _btnBrand.frame;
    origFrame.size.width = newSize.width+5;
    origFrame.origin.x = _btnBrand.superview.frame.size.width-5-origFrame.size.width;
    
    _btnBrand.frame = origFrame;
    _lblCoupons.text = [NSString stringWithFormat:@"%d",_data.couponTotal];
    _lblCoupons.font = ME_FONT(12);
    _lblCoupons.textColor = [UIColor colorWithRed:229 green:0 blue:79];
    [_lblFavorCount setValue:[NSString stringWithFormat:@"%d" ,_data.favorTotal] forKey:@"text"];
    [self bringSubviewToFront:_lblCoupons];
    _lblFavorCount.font = ME_FONT(12);
    _lblFavorCount.textColor = [UIColor colorWithRed:229 green:0 blue:79];
      [self bringSubviewToFront:_lblFavorCount];
    _lblDescrip.text = [_data.descrip trimReturnEmptyChar];
    _lblDescrip.font = ME_FONT(12);
    _lblDescrip.textColor = [UIColor colorWithRed:102 green:102 blue:102];
    _lblDescrip.numberOfLines = 0;
    origFrame = _lblDescrip.frame;
    CGSize fitSize = [_lblDescrip sizeThatFits:_lblDescrip.frame.size];
    origFrame.size.height = fitSize.height;
    origFrame.size.width = fitSize.width;
    origFrame.origin.y = _imgLikeBG.frame.size.height+_imgLikeBG.frame.origin.y+2;
    _lblDescrip.frame = origFrame;
    FSResource *imgObj = [_data.resource lastObject];
    if (imgObj)
    {
        CGSize cropSize = CGSizeMake(300, 300 );
        [_imgView setImageUrl:imgObj.absoluteUrl320 resizeWidth:cropSize];
    }
    [_btnStore setTitle:[NSString stringWithFormat:@"%@ \(%d公里)",_data.store.name,(int)_data.store.distance/1000] forState:UIControlStateNormal];
    _btnStore.titleLabel.font = ME_FONT(14);
    [_btnStore setTitleColor:[UIColor colorWithRed:229 green:0 blue:79] forState:UIControlStateNormal];
    CGSize storesize =[_btnStore sizeThatFits:_btnStore.frame.size];
    _btnStore.frame = CGRectMake(_btnStore.frame.origin.x, _lblDescrip.frame.size.height+_lblDescrip.frame.origin.y+2, storesize.width, storesize.height);
    if (_data.price &&
        [_data.price intValue]>0)
    {
        _btnPrice.alpha =1;
        [_btnPrice setTitle:[NSString stringWithFormat:@"¥%d",[_data.price intValue]] forState:UIControlStateNormal];
        [_btnPrice setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnPrice.titleLabel.font = [UIFont systemFontOfSize:14];
        CGSize newsize = [_btnPrice sizeThatFits:_btnPrice.frame.size];
        _btnPrice.frame = CGRectMake(_imgView.frame.size.width+_imgView.frame.origin.x-newsize.width, _imgView.frame.size.height+_imgView.frame.origin.y-newsize.height, newsize.width, newsize.height);
    } else
    {
        _btnPrice.alpha = 0;
    }
    CGRect superFrame =   _btnStore.superview.frame;
    superFrame.size.height = _btnStore.frame.size.height +_btnStore.frame.origin.y+2;
    _btnStore.superview.frame = superFrame;
    CGRect commentFrame = _tbComment.frame;
    commentFrame.origin.y = superFrame.origin.y+superFrame.size.height+2;
    _tbComment.frame = commentFrame;
}

-(void)updateInteraction:(id)updatedEntity
{
    _data.isFavored = [(FSProdItemEntity *)updatedEntity isFavored];
    _data.isCouponed = [(FSProdItemEntity *)updatedEntity isCouponed];
    
}

-(void) resetScrollViewSize
{
    UITableView *table = self.tbComment;
    CGRect origiFrame = table.frame;
    origiFrame.size.height = PRO_DETAIL_COMMENT_CELL_HEIGHT * _data.comments.count+PRO_DETAIL_COMMENT_HEADER_HEIGHT + PRO_DETAIL_COMMENT_CELL_HEIGHT;
    [table setFrame:origiFrame];
    CGSize originContent = self.svContent.contentSize;
    originContent.height = origiFrame.size.height +self.imgView.frame.size.height + _btnStore.superview.frame.size.height+4;//+PRO_DETAIL_COMMENT_INPUT_HEIGHT+4;
    originContent.width = MAX(originContent.width, self.frame.size.width);
    self.svContent.contentSize = originContent;
    
}

-(void) willRemoveFromSuper
{
    _imgView.image = nil;
    _data = nil;
}

@end