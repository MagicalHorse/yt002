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
#import "FSProdItemEntity.h"
#import "FSProItemEntity.h"

#define PRO_DETAIL_COMMENT_INPUT_TAG 200
#define TOOLBAR_HEIGHT 44
#define PRO_DETAIL_COMMENT_INPUT_HEIGHT 63
#define PRO_DETAIL_COMMENT_CELL_HEIGHT 73
#define PRO_DETAIL_COMMENT_HEADER_HEIGHT 30

@interface FSProdDetailView ()
{
    FSProdItemEntity *_data;
    float couponLeft;
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
    [self unregisterKVO];
    _imgThumb = nil;
    _data = nil;
    _btnBrand = nil;

}
-(void)setData:(id)data
{
    [self unregisterKVO];
    _data = data;
    [self registerKVO];
    
    int yOffset = 0;
    
    //_imgView && _audioResource
    FSResource *_audioResource = nil;
    if (_data.resource &&
        _data.resource.count>0)
    {
        for (FSResource *imgObj in _data.resource) {
            if (imgObj.type == 2) {
                _audioResource = imgObj;
                break;
            }
        }
        for (FSResource *imgObj in _data.resource) {
            if (imgObj.type == 1) {
                if (imgObj.width <= 0.0000001) {
                    break;
                }
                int _imgHeight = imgObj.height*_imgView.frame.size.width/imgObj.width;
                CGSize cropSize = CGSizeMake(_imgView.frame.size.width, _imgHeight);
                [_imgView setImageUrl:imgObj.absoluteUrl320 resizeWidth:CGSizeMake(cropSize.width*RetinaFactor, cropSize.height*RetinaFactor) placeholderImage:nil];//[UIImage imageNamed:@"default_icon320.png"]
                CGRect _rect = _imgView.frame;
                _rect.size.height = _imgHeight;
                _imgView.frame = _rect;
                yOffset = _imgView.frame.origin.y + _imgView.frame.size.height;
                _imageURL = imgObj.absoluteUrl320.absoluteString;
                break;
            }
        }
    }
    
    //_imgThumb
    _imgThumb.ownerUser = _data.fromUser;
    CGRect _rect = _imgThumb.frame;
    _rect.origin.y = yOffset - 20;
    _imgThumb.frame = _rect;
    
    //_lblNickie
    _lblNickie.text = _data.fromUser.nickie;
    _lblNickie.font = ME_FONT(14);
    _lblNickie.textColor =[UIColor colorWithHexString:@"#181818"];
    [_lblNickie sizeToFit];
    _rect = _lblNickie.frame;
    _rect.origin.y = yOffset + _imgThumb.frame.size.height - 17;
    _lblNickie.frame = _rect;
    
    //_btnPrice
    if (_data.price && [_data.price intValue]>0)
    {
        _btnPrice.hidden = NO;
        [_btnPrice setTitle:[NSString stringWithFormat:@"¥%lld元",[_data.price longLongValue]] forState:UIControlStateNormal];
        _btnPrice.backgroundColor = [UIColor clearColor];
        [_btnPrice setTitleColor:[UIColor colorWithHexString:@"#e5004f"] forState:UIControlStateNormal];
        _btnPrice.titleLabel.font = [UIFont systemFontOfSize:14];
        CGSize newsize = [_btnPrice sizeThatFits:_btnPrice.frame.size];
        _btnPrice.frame = CGRectMake(0, 0, newsize.width, newsize.height);
        _btnPrice.center = CGPointMake(160, yOffset + 35 - newsize.height/2);
    }
    else {
        _btnPrice.hidden = YES;
    }
    
    //_btnBrand
    [_btnBrand setTitleColor:[UIColor colorWithRed:51 green:51 blue:51] forState:UIControlStateNormal];
    NSString *brand = [NSString stringWithFormat:@"%@",_data.brand.name];
    [_btnBrand setTitle:brand forState:UIControlStateNormal];
    _btnBrand.titleLabel.font = ME_FONT(14);
    _btnBrand.titleLabel.minimumFontSize = 10;
    _btnBrand.titleLabel.adjustsFontSizeToFitWidth = YES;
    UIImage *image = [UIImage imageNamed:@"brand_btn.png"];
    [_btnBrand setBackgroundImage:image forState:UIControlStateNormal];
    [_btnBrand setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rect = _btnBrand.frame;
    _rect.origin.y = yOffset + 10;
    _btnBrand.frame = _rect;
    
    //设置播放按钮
    if (_audioResource) {
        _audioButton = [[FSAudioButton alloc] initWithFrame:CGRectMake(0, 0, 65, 26)];
        _audioButton.center = CGPointMake(160, yOffset);
        NSMutableString *newPath = [NSMutableString stringWithString:_audioResource.relativePath];
        [newPath replaceOccurrencesOfString:@"\\" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0,newPath.length)];
        _audioButton.fullPath = [NSString stringWithFormat:@"%@%@.mp3", _audioResource.domain,newPath];
        _audioButton.audioTime = [NSString stringWithFormat:@"%d''", (_audioResource.width>0?_audioResource.width:1)];
        [_imgNameView addSubview:_audioButton];
    }
    
    yOffset = _lblNickie.frame.origin.y + _lblNickie.frame.size.height + 5;
    
    //_imgNameView
    _rect = _imgNameView.frame;
    _rect.size.height = yOffset;
    _imgNameView.frame = _rect;
    _viewHeight = yOffset;
    
    yOffset = 0;
    //在线咨询按钮和在线订购
    int _x = 15;
    if (!_data.is4sale) {
        _x = 93;
        _btnBuy.hidden = YES;
    }
    else{
        _btnBuy.hidden = NO;
        _rect = _btnBuy.frame;
        _rect.origin.x = _x + 20 + _btnContact.frame.size.width;
        _btnBuy.frame = _rect;
    }
    _rect = _btnContact.frame;
    _rect.origin.x = _x;
    _btnContact.hidden = NO;
    _btnContact.frame = _rect;
    yOffset += 50;
    
    //_lblFavorCount
    [_lblFavorCount setValue:[NSString stringWithFormat:@"%d" ,_data.favorTotal] forKey:@"text"];
    [self bringSubviewToFront:_lblCoupons];
    _lblFavorCount.font = ME_FONT(13);
    _lblFavorCount.textColor = [UIColor colorWithHexString:@"#e5004f"];
    [self bringSubviewToFront:_lblFavorCount];
    
    //_lblCoupons
    _lblCoupons.text = [NSString stringWithFormat:@"%d",_data.couponTotal];
    _lblCoupons.font = ME_FONT(13);
    _lblCoupons.textColor = [UIColor colorWithHexString:@"#e5004f"];
    
    _rect = _countView.frame;
    _rect.origin.y = yOffset;
    _countView.frame = _rect;
    yOffset += _rect.size.height + 10;
    
    //_lblDescrip
    _lblDescrip.text = _data.descrip;
    _lblDescrip.font = ME_FONT(14);
    _lblDescrip.textColor = [UIColor colorWithHexString:@"#666666"];
    _lblDescrip.numberOfLines = 0;
    CGSize fitSize = [_lblDescrip sizeThatFits:_lblDescrip.frame.size];
    _rect = _lblDescrip.frame;
    _rect.origin.y = yOffset;
    _rect.size.width = fitSize.width;
    _rect.size.height = fitSize.height;
    _lblDescrip.frame = _rect;
    yOffset += _lblDescrip.frame.size.height + 10;
    
    //_btnStore
    NSString *distanceString = [NSString stringMetersFromDouble:_data.store.distance];
    if (distanceString.length > 0)
    {
        [_btnStore setTitle:[NSString stringWithFormat:@"%@ \(%@)",_data.store.name,distanceString] forState:UIControlStateNormal];
    } else
    {
        [_btnStore setTitle:_data.store.name forState:UIControlStateNormal];
    }
    _btnStore.titleLabel.font = ME_FONT(14);
    [_btnStore setTitleColor:[UIColor colorWithHexString:@"#e5004f"] forState:UIControlStateNormal];
    [_btnStore setTitleColor:[UIColor colorWithHexString:@"#e5004f"] forState:UIControlStateHighlighted];
    CGSize storesize =[_btnStore sizeThatFits:_btnStore.frame.size];
    _rect = _btnStore.frame;
    _rect.origin.y = yOffset;
    _rect.size.width = storesize.width;
    _rect.size.height = storesize.height;
    _btnStore.frame = _rect;
    yOffset += _btnStore.frame.size.height + 10;
    
    _rect = _descAddView.frame;
    _rect.origin.y = _viewHeight;
    _rect.size.height = yOffset;
    _descAddView.frame = _rect;
    [self bringSubviewToFront:_descAddView];
    _viewHeight += yOffset;
    
    //_tbComment
    _rect = _tbComment.frame;
    _rect.origin.y = _viewHeight;
    _tbComment.frame = _rect;
    
    [self updateInteraction];
    
    self.svContent.frame = CGRectMake(0, 0, APP_WIDTH, APP_HIGH - NAV_HIGH - TOOLBAR_HEIGHT);
    self.svContent.showsVerticalScrollIndicator = YES;
    
    [self showControls:NO];
    
    _imgNameView.backgroundColor = [UIColor whiteColor];
    _descAddView.backgroundColor = APP_TABLE_BG_COLOR;
    _tbComment.backgroundColor = APP_TABLE_BG_COLOR;
    _tbComment.backgroundView = nil;
    
    [_btnFavor setTitle:@"喜欢"];
}

-(void)showControls:(BOOL)flag
{
    _imgNameView.hidden = flag;
    _descAddView.hidden = flag;
    _tbComment.hidden = flag;
}

-(void)registerKVO
{
    if (_data)
    {
        [_data addObserver:self forKeyPath:@"couponTotal" options:NSKeyValueObservingOptionNew context:nil];
        [_data addObserver:self forKeyPath:@"favorTotal" options:NSKeyValueObservingOptionNew context:nil];
        [_data addObserver:self forKeyPath:@"isFavored" options:NSKeyValueObservingOptionNew context:nil];
    }
}
-(void)unregisterKVO
{
    if (_data)
    {
        [_data removeObserver:self forKeyPath:@"couponTotal"];
        [_data removeObserver:self forKeyPath:@"favorTotal"];
        [_data removeObserver:self forKeyPath:@"isFavored"];
    }
}

-(void)updateChangeInteraction:(NSArray *)info
{
    NSString *key = info[0];
    if ([key isEqualToString:@"couponTotal"])
    {
        _lblCoupons.text = [NSString stringWithFormat:@"%d",_data.couponTotal];
    } else if([key isEqualToString:@"favorTotal"])
    {
        _lblFavorCount.text = [NSString stringWithFormat:@"%d",_data.favorTotal];
    } else if ([key isEqualToString:@"isFavored"])
    {
        [self updateInteraction];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (![NSThread isMainThread]) {
        
		[self performSelectorOnMainThread:@selector(updateChangeInteraction:) withObject:@[keyPath,object] waitUntilDone:NO];
	} else {
		[self updateChangeInteraction:@[keyPath,object]];
	}
}

-(void)dealloc
{
    [self unregisterKVO];
}

-(void)updateInteraction
{
    NSString *name = !_data.isFavored?@"bottom_nav_like_icon":@"bottom_nav_notlike_icon";
    UIImage *sheepImage = [UIImage imageNamed:name];
    if (!_btnFavor.customView)
    {
        UIButton *sheepButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sheepButton setShowsTouchWhenHighlighted:YES];
        [sheepButton addTarget:_tbComment.delegate
                            action:@selector(doFavor:)
              forControlEvents:UIControlEventTouchUpInside];
        _btnFavor.customView = sheepButton;
    }
    UIButton *sheepButton = (UIButton*)_btnFavor.customView;
    [sheepButton setImage:sheepImage forState:UIControlStateNormal];
    [sheepButton sizeToFit];
}

-(void)updateToolBar:(BOOL)flag
{
    //更新优惠按钮
    if (!flag) {
        NSMutableArray *_array = [NSMutableArray arrayWithArray:self.myToolBar.items];
        if (_array.count >= 7) {
            [_array removeObject:_fixibleItem3];
            [_array removeObject:_btnCoupon];
            _fixibleItem1.width = 70;
            _fixibleItem4.width = 70;
            [self.myToolBar setItems:_array animated:NO];
        }
    }
    else {
        NSMutableArray *_array = [NSMutableArray arrayWithArray:self.myToolBar.items];
        if (_array.count < 7) {
            [_array insertObject:_fixibleItem3 atIndex:4];
            [_array insertObject:_btnCoupon atIndex:5];
            _fixibleItem1.width = 40;
            _fixibleItem4.width = 40;
            [self.myToolBar setItems:_array animated:NO];
        }
    }
}

-(void)setToolBarBackgroundImage
{
    UIImage *_image = [UIImage imageNamed:@"toolbar_bg.png"];
    [self.myToolBar setBackgroundImage:_image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

-(void) resetScrollViewSize
{
    UITableView *table = self.tbComment;
    CGRect origiFrame = table.frame;
    origiFrame.origin.y = _viewHeight;
    CGFloat totalHeight = 0;
    BOOL isBind = [self IsBindPromotionOrProduct:_data];
    int section = isBind?1:0;
    int commentCount = _data.comments.count;
    while (--commentCount >=0) {
        double _height = [_tbComment.delegate tableView:_tbComment heightForRowAtIndexPath:[NSIndexPath indexPathForItem:commentCount inSection:section]];
        totalHeight += _height;
    }
    origiFrame.size.height = totalHeight + PRO_DETAIL_COMMENT_HEADER_HEIGHT + (isBind?70:0) + (_data.comments.count>0?0:50);
    [table setFrame:origiFrame];
    CGSize originContent = self.svContent.contentSize;
    originContent.height = origiFrame.size.height + _viewHeight;
    originContent.width = 320;
    self.svContent.contentSize = originContent;
}

-(BOOL)IsBindPromotionOrProduct:(id)_item
{
    if (!_item) {
        return NO;
    }
    if ([_item isKindOfClass:[FSProdItemEntity class]]) {
        if (((FSProdItemEntity*)_item).promotions.count > 0) {
            return YES;
        }
    }
    else if([_item isKindOfClass:[FSProItemEntity class]]) {
        return [((FSProItemEntity*)_item).isProductBinded boolValue];
    }
    
    return NO;
}

-(void) willRemoveFromSuper
{
    _imgView.image = nil;
    _data = nil;
}

@end