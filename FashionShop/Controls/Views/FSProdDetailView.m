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
    self.backgroundColor = [UIColor colorWithRed:229 green:229 blue:229];
    _imgThumb.ownerUser = _data.fromUser;
    _lblNickie.text = _data.fromUser.nickie;
    _lblNickie.font = ME_FONT(15);
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
    
    int yOff = 5 + _imgLikeBG.frame.size.height+_imgLikeBG.frame.origin.y;
    
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
                CGSize cropSize = CGSizeMake(_imgView.frame.size.width, _imgView.frame.size.height );
                [_imgView setImageUrl:imgObj.absoluteUrl320 resizeWidth:CGSizeMake(cropSize.width*RetinaFactor, cropSize.height*RetinaFactor) placeholderImage:[UIImage imageNamed:@"default_icon320.png"]];
                _imageURL = imgObj.absoluteUrl320.absoluteString;
                //显示更多图片标识
                UIImage *moreInd = [UIImage imageNamed:@"more_img_icon"];
                UIImageView *moreImages = [[UIImageView alloc] initWithFrame:CGRectMake(_imgView.frame.size.width/2-moreInd.size.width/2, _imgView.frame.size.height+_imgView.frame.origin.y-moreInd.size.height, moreInd.size.width, moreInd.size.height)];
                moreImages.image = moreInd;
                [_imgView.superview addSubview:moreImages];
                [_imgView.superview bringSubviewToFront:moreImages];
                break;
            }
        }
    }
    
    CGRect _rect = _lblDescrip.frame;
    if (_audioResource) {
        _rect.size.width = 233;
    }
    _lblDescrip.frame = _rect;
    _lblDescrip.text = [_data.descrip trimReturnEmptyChar];
    _lblDescrip.font = ME_FONT(14);
    _lblDescrip.textColor = [UIColor colorWithRed:102 green:102 blue:102];
    _lblDescrip.numberOfLines = 0;
    origFrame = _lblDescrip.frame;
    CGSize fitSize = [_lblDescrip sizeThatFits:_lblDescrip.frame.size];
    origFrame.size.height = fitSize.height;
    origFrame.size.width = fitSize.width;
    origFrame.origin.y = yOff;
    _lblDescrip.frame = origFrame;
    yOff += _lblDescrip.frame.size.height + 5;
  
    UIView *imgBG = [[UIView alloc] initWithFrame:CGRectMake(0, _imgView.frame.origin.y, self.frame.size.width, _imgView.frame.size.height)];
    imgBG.userInteractionEnabled = FALSE;
    imgBG.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"prod_detail_bg"]];
    [_imgView.superview addSubview:imgBG];
    [_imgView.superview sendSubviewToBack:imgBG];
    NSString *distanceString = [NSString stringMetersFromDouble:_data.store.distance];
    if (distanceString.length > 0)
    {
        [_btnStore setTitle:[NSString stringWithFormat:@"%@ \(%@)",_data.store.name,distanceString] forState:UIControlStateNormal];
    } else
    {
        [_btnStore setTitle:_data.store.name forState:UIControlStateNormal];
    }
    _btnStore.titleLabel.font = ME_FONT(14);
    [_btnStore setTitleColor:[UIColor colorWithRed:229 green:0 blue:79] forState:UIControlStateNormal];
    [_btnStore setTitleColor:[UIColor colorWithRed:229 green:0 blue:79] forState:UIControlStateHighlighted];
    CGSize storesize =[_btnStore sizeThatFits:_btnStore.frame.size];
    _btnStore.frame = CGRectMake(_btnStore.frame.origin.x, yOff, storesize.width, storesize.height + 10);
    yOff += _btnStore.frame.size.height + 5;
    if (_data.price &&
        [_data.price intValue]>0)
    {
        _btnPrice.alpha =1;
        [_btnPrice setTitle:[NSString stringWithFormat:@"¥%lld",[_data.price longLongValue]] forState:UIControlStateNormal];
        [_btnPrice setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnPrice.titleLabel.font = [UIFont systemFontOfSize:14];
        CGSize newsize = [_btnPrice sizeThatFits:_btnPrice.frame.size];
        _btnPrice.frame = CGRectMake(_imgView.frame.size.width+_imgView.frame.origin.x-newsize.width,
                                     _imgView.frame.size.height+_imgView.frame.origin.y-newsize.height - 5,
                                     newsize.width,
                                     newsize.height);
    } else
    {
        _btnPrice.alpha = 0;
    }
    _btnStore.superview.hidden = NO;
    CGRect superFrame = _btnStore.superview.frame;
    superFrame.size.height = yOff;//_btnStore.frame.size.height +_btnStore.frame.origin.y+yOff;
    _btnStore.superview.frame = superFrame;
    CGRect commentFrame = _tbComment.frame;
    commentFrame.origin.y = superFrame.origin.y+superFrame.size.height;
    _tbComment.frame = commentFrame;
    
    //设置播放按钮
    if (_audioResource) {
        _audioButton = [[FSAudioButton alloc] initWithFrame:CGRectMake(260, (superFrame.size.height-21 - 50)/2 + 21, 50, 50)];
        [_audioButton setBackgroundImage:[UIImage imageNamed:@"audio_btn_100x100.png"] forState:UIControlStateNormal];
        NSMutableString *newPath = [NSMutableString stringWithString:_audioResource.relativePath];
        [newPath replaceOccurrencesOfString:@"\\" withString:@"/" options:NSCaseInsensitiveSearch range:NSMakeRange(0,newPath.length)];
        _audioButton.fullPath = [NSString stringWithFormat:@"%@%@.mp3", _audioResource.domain,newPath];
        _audioButton.audioTime = [NSString stringWithFormat:@"%d''", (_audioResource.width>0?_audioResource.width:1)];
        [_audioButton setTitleFrame:CGRectMake(0, 10, _audioButton.frame.size.width/7*4, _audioButton.frame.size.height - 20)];
        [_audioButton setPlayButtonFrame:CGRectMake(_audioButton.frame.size.width/7*4 + 1, (_audioButton.frame.size.height-12)/2, 12, 12)];
        [_btnStore.superview addSubview:_audioButton];
    }
    
    [self updateInteraction];
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

-(void)updateToolBar:(id)data
{
    _data = data;
    //更新优惠按钮
    if (!_data.hasPromotion) {
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
    UIImage *_image = [UIImage imageNamed:@"Toolbar_bg.png"];
    [self.myToolBar setBackgroundImage:_image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

-(void) resetScrollViewSize
{
    UITableView *table = self.tbComment;
    CGRect origiFrame = table.frame;
    CGFloat totalHeight = 0;
    int commentCount = _data.comments.count;
    while (--commentCount >=0) {
        totalHeight+= [_tbComment.delegate tableView:_tbComment heightForRowAtIndexPath:[NSIndexPath indexPathForItem:commentCount inSection:0]];
    }
    //origiFrame.size.height = totalHeight+PRO_DETAIL_COMMENT_HEADER_HEIGHT + PRO_DETAIL_COMMENT_CELL_HEIGHT + (_data.hasPromotion?40:0);
    origiFrame.size.height = PRO_DETAIL_COMMENT_CELL_HEIGHT * _data.comments.count+PRO_DETAIL_COMMENT_HEADER_HEIGHT + PRO_DETAIL_COMMENT_CELL_HEIGHT + (_data.hasPromotion?40:0);
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