//
//  FSProdDetailCell.m
//  FashionShop
//
//  Created by gong yi on 12/10/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProdDetailCell.h"
#import "FSResource.h"

@implementation FSProdDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)prepareForReuse
{
    _imgPic.image = nil;
}
-(void)setData:(FSProdItemEntity *)data
{
    _data = data;
    
    if (_data.price &&
        [_data.price intValue]>0)
    {
        _btnPrice.alpha =0.6;
        [_btnPrice setTitle:[NSString stringWithFormat:@"¥%d",[_data.price intValue]] forState:UIControlStateNormal];
        [_btnPrice setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnPrice.titleLabel.font = [UIFont systemFontOfSize:9];
        CGSize newsize = [_btnPrice sizeThatFits:_btnPrice.frame.size];
        _btnPrice.frame = CGRectMake(self.frame.size.width-newsize.width, self.frame.size.height-newsize.height - 5, newsize.width, newsize.height);
    }
    else
    {
        _btnPrice.alpha = 0;
    }
}

-(void) showProIcon
{
    _btnPro.hidden = NO;
    _btnPro.frame = CGRectMake(0, 0,25, 25);
}

-(void) hidenProIcon
{
    _btnPro.hidden = YES;
}

- (void)imageContainerStartDownload:(id)container withObject:(id)indexPath andCropSize:(CGSize)crop
{
    if (!_imgPic.image)
    {
        if (_data.resource && _data.resource.count>0)
        {
            NSURL *url = [(FSResource *)_data.resource[0] absoluteUrl];
            if (url)
            {
                [_imgPic setImageUrl:url resizeWidth:CGSizeMake(crop.width*RetinaFactor, crop.height*RetinaFactor) placeholderImage:[UIImage imageNamed:@"default_icon120.png"]];
            }
        }
        
    }
}


-(void)willRemoveFromView
{
    _imgPic.image = nil;
}
@end
