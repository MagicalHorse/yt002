//
//  FSSuggestCell.h
//  FashionShop
//
//  Created by gong yi on 11/14/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSFavor.h"
#import "UIImageView+WebCache.h"



@interface FSFavorProCell : PSUICollectionViewCell<ImageContainerDownloadDelegate>

@property (assign, nonatomic) IBOutlet UIImageView *imgResource;

@property (strong,nonatomic) FSFavor *data;
@property (strong,nonatomic) UIButton *deleteButton;


-(void) willRemoveFromView;
@end
