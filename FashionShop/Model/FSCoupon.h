//
//  FSCoupon.h
//  FashionShop
//
//  Created by gong yi on 12/5/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSModelBase.h"
#import "FSProItemEntity.h"
#import "FSProdItemEntity.h"

@interface FSCoupon : FSModelBase
@property (nonatomic) int32_t id;
@property (nonatomic, retain) NSString * code;
@property (nonatomic) int32_t productid;
@property (nonatomic) FSSourceType producttype;
@property (nonatomic, retain) NSString * productname;
@property (nonatomic,strong) FSProItemEntity *promotion;
@property (nonatomic,strong) FSProdItemEntity *product;
@property (nonatomic,strong) NSString *pass;
@end
