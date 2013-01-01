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
    _lblDescrip.text = _data.descrip;
    _lblDescrip.font = ME_FONT(12);
    _lblDescrip.textColor = [UIColor colorWithRed:102 green:102 blue:102];
    _lblDescrip.numberOfLines = 2;
    origFrame = _lblDescrip.frame;
    CGSize fitSize = [_lblDescrip sizeThatFits:_lblDescrip.frame.size];
    origFrame.size.height = fitSize.height;
    origFrame.size.width = fitSize.width;
    _lblDescrip.frame = origFrame;
    FSResource *imgObj = [_data.resource lastObject];
    if (imgObj)
    {
        CGSize cropSize = CGSizeMake(300, 300 );
        [_imgView setImageUrl:imgObj.absoluteUrl320 resizeWidth:cropSize];
    }
    
    _lblStoreAddress.text = [NSString stringWithFormat:@"%@ \(%d公里)",_data.store.name,(int)_data.store.distance/1000];
    _lblStoreAddress.font = ME_FONT(14);
    _lblStoreAddress.textColor = [UIColor colorWithRed:229 green:0 blue:79];

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
    originContent.height = origiFrame.size.height +self.imgView.frame.size.height + _lblStoreAddress.superview.frame.size.height+PRO_DETAIL_COMMENT_INPUT_HEIGHT+4;
    originContent.width = MAX(originContent.width, self.frame.size.width);
    self.svContent.contentSize = originContent;
    
}

-(void) willRemoveFromSuper
{
    _imgView.image = nil;
    _data = nil;
}

@end