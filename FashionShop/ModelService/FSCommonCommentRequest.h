//
//  FSCommonCommentRequest.h
//  FashionShop
//
//  Created by gong yi on 12/13/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSEntityRequestBase.h"
#define RK_REQUEST_COMMENT_LIST @"/comment/list"
#define RK_REQUEST_COMMENT_SAVE @"/comment/create"

@interface FSCommonCommentRequest : FSEntityRequestBase

@property(nonatomic,strong) NSNumber *id;
@property(nonatomic,strong) NSNumber *sourceid;
@property(nonatomic,strong) NSNumber *sourceType;//0:product,1:promotion
@property(nonatomic,strong) NSNumber *nextPage;
@property(nonatomic,strong) NSNumber *pageSize;
@property(nonatomic,strong) NSNumber *sort;
@property(nonatomic,strong) NSDate *refreshTime;
@property(nonatomic,strong) NSNumber* userId;
@property(nonatomic,strong) NSString * userToken;
@property(nonatomic,strong) NSString *comment;

@end
