//
//  FSProDetailView.h
//  FashionShop
//
//  Created by gong yi on 12/4/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "SYPageView.h"
#import "FSDetailBaseView.h"
#import "FSProItemEntity.h"



@interface FSProDetailView : FSDetailBaseView
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblFavorCount;
@property (strong, nonatomic) IBOutlet UILabel *lblDuration;
@property (strong, nonatomic) IBOutlet UILabel *lblCoupons;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *lblDescrip;
@property (strong, nonatomic) IBOutlet UILabel *couponTitle;
@property (strong, nonatomic) IBOutlet UILabel *likeTitle;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnFavor;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCoupon;
//@property (strong, nonatomic) IBOutlet UIToolbar *myToolBar;

@property (strong, nonatomic) IBOutlet UIButton *btnStore;

@property (strong, nonatomic) IBOutlet UIScrollView *svContent;

@property (strong, nonatomic) IBOutlet UIImageView *imgFansBG;
@property (strong, nonatomic) IBOutlet UIButton *btnTag;

@property (strong, nonatomic) IBOutlet UITableView *tbComment;


@end
