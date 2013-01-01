//
//  FSProItemEntity.h
//  FashionShop
//
//  Created by gong yi on 11/17/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSEntityBase.h"
#import "FSModelBase.h"
#import "FSStore.h"
#import "FSResource.h"
#import "FSUser.h"

@interface FSProItemEntity : FSModelBase

@property (nonatomic, assign) NSInteger  id;
@property (nonatomic, assign) NSInteger  type;
@property (nonatomic, strong) FSStore * store;
@property (nonatomic,strong) NSMutableArray * resource;
@property (nonatomic,assign) double storeDistance;

@property (nonatomic, strong) NSString * descrip;
@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSDate * endDate;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * proImgs;
@property (nonatomic, strong) FSUser * fromUser;
@property (nonatomic, strong) NSDate * inDate;
@property (nonatomic,assign) NSInteger couponTotal;
@property (nonatomic,assign) NSInteger favorTotal;
@property (nonatomic,strong) NSMutableArray *coupons;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic,assign) BOOL isFavored;
@property (nonatomic,assign) BOOL isCouponed;


@end
