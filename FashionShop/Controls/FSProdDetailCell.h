//
//  FSProdDetailCell.h
//  FashionShop
//
//  Created by gong yi on 12/10/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSProdItemEntity.h"
#import "UIImageView+WebCache.h"

@interface FSProdDetailCell : PSUICollectionViewCell<ImageContainerDownloadDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imgPic;


@property(nonatomic,strong) FSProdItemEntity *data;

-(void)willRemoveFromView;
@end
