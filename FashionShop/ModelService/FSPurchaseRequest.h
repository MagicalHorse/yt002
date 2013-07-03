//
//  FSPurchaseRequest.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-28.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSEntityRequestBase.h"

#define RK_REQUEST_PROD_BUY_INFO    @"/product/detail4p"        //获取实时商品购买详情
#define RK_REQUEST_PROD_BUY_AMOUNT  @"/product/computeamount"   //计算订单金额
#define RK_REQUEST_PROD_ORDER       @"/product/order"           //产生订单
#define RK_REQUEST_ORDER_CANCEL     @"/order/void"              //取消订单
#define RK_REQUEST_ORDER_LIST       @"/order/my"                //我的订单列表
#define RK_REQUEST_ORDER_DETAIL     @"/order/detail"            //订单详情
#define RK_REQUEST_ORDER_RMA        @"/order/rma"               //申请退货

@interface FSPurchaseRequest : FSEntityRequestBase

@property(nonatomic,strong) NSString *uToken;
@property(nonatomic,strong) NSNumber *id;
@property(nonatomic,strong) NSNumber *quantity;//数量
@property(nonatomic,strong) NSString *order;

@property(nonatomic) int type;//订单类型:1,2,3
@property(nonatomic,strong) NSNumber* nextPage;
@property(nonatomic,strong) NSNumber* pageSize;

@property(nonatomic,strong) NSString *orderno;//订单号

//退货参数
@property(nonatomic,strong) NSString *reason;//退货理由
@property(nonatomic,strong) NSString *bankname;//银行名称
@property(nonatomic,strong) NSString *bankcard;//银行卡号
@property(nonatomic,strong) NSString *bankaccount;//银行用户名
@property(nonatomic,strong) NSString *contactphone;//电话


@end
