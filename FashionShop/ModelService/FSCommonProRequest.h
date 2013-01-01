//
//  FSProUploadRequest.h
//  FashionShop
//
//  Created by gong yi on 11/30/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSEntityRequestBase.h"
#import "FSComment.h"


#define RK_REQUEST_PRO_UPLOAD @"/promotion/create"
#define RK_REQUEST_PRO_DETAIL @"/promotion/detail"
#define RK_REQUEST_PROD_UPLOAD @"/product/create"
#define RK_REQUEST_PROD_DETAIL @"/product/detail"

@interface FSCommonProRequest : FSEntityRequestBase<RKRequestDelegate>

@property(nonatomic,strong) NSString *uToken;
@property(nonatomic,strong) UIImage *img;
@property(nonatomic,strong) NSNumber * storeId;
@property(nonatomic,strong) NSString *storeName;
@property(nonatomic,strong) NSNumber * tagId;
@property(nonatomic,strong) NSString *tagName;
@property(nonatomic,strong) NSString *descrip;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSNumber * brandId;
@property(nonatomic,strong) NSString * brandName;
@property(nonatomic,strong) NSNumber *id;
@property(nonatomic,strong) NSNumber *longit;
@property(nonatomic,strong) NSNumber *lantit;
@property(nonatomic,strong) NSDate* startdate;
@property(nonatomic,strong) NSDate* enddate;
@property(nonatomic,strong) FSComment *comment;
@property(nonatomic) FSSourceType pType;

- (void)upload:(dispatch_block_t)blockcomplete error:(dispatch_block_t)blockerror;
@end
