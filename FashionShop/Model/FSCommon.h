//
//  FSCommon.h
//  FashionShop
//
//  Created by HeQingshan on 13-5-10.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSModelBase.h"

@interface FSCommon : FSModelBase

@property (nonatomic) NSNumber* rangefrom;
@property (nonatomic) NSNumber* rangeto;
@property (nonatomic) NSNumber* ratio;

//积点兑换使用
@property (nonatomic, assign) NSInteger storeid;
@property (nonatomic, strong) NSString * storename;
@property (nonatomic,strong) NSString *excludes;//活动范围

@end
