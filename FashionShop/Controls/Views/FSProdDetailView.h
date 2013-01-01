//
//  FSProdDetailView.h
//  FashionShop
//
//  Created by gong yi on 12/14/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "SYPageView.h"
#import "FSDetailBaseView.h"
#import "FSProdItemEntity.h"
#import "FSThumView.h"

@interface FSProdDetailView : FSDetailBaseView


@property (strong, nonatomic) IBOutlet UILabel *lblFavorCount;

@property (strong, nonatomic) IBOutlet FSThumView *imgThumb;

@property (strong, nonatomic) IBOutlet UILabel *lblNickie;
@property (strong, nonatomic) IBOutlet UIButton *btnBrand;

@property (strong, nonatomic) IBOutlet UILabel *lblCoupons;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *lblDescrip;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnFavor;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCoupon;

@property (strong, nonatomic) IBOutlet UILabel *lblStoreAddress;


@property (strong, nonatomic) IBOutlet UIScrollView *svContent;

@property (strong, nonatomic) IBOutlet UITableView *tbComment;

@end
