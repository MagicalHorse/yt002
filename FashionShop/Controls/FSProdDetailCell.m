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

-(void)setData:(FSProdItemEntity *)data
{
    _data = data;
    
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
                [_imgPic setImageUrl:url resizeWidth:crop];
            }
        }
        
    }
}


-(void)willRemoveFromView
{
    _imgPic.image = nil;
}
@end
