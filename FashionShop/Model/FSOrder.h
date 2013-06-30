//
//  FSOrder.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-22.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSModelBase.h"
#import "FSResource.h"
#import "FSProdItemEntity.h"

@interface FSOrderInfo : FSModelBase

@property (nonatomic, strong) NSString *orderno;//订单编号
@property (nonatomic) float totalamount;//订单金额

@property (nonatomic) BOOL needinvoice;//是否需要发票
@property (nonatomic,strong) NSString *invoicesubject;//发票抬头
@property (nonatomic,strong) NSString *invoicedetail;//发票明细

@property (nonatomic) BOOL canrma;//当前是否可以退货
@property (nonatomic,strong) NSString *rmas;//退货信息

@property (nonatomic,strong) NSString *shippingaddress;//地址全称
@property (nonatomic,strong) NSString *shippingno;//地址ID？
@property (nonatomic,strong) NSString *shippingvianame;//?
@property (nonatomic) float shippingfee;//运费
@property (nonatomic,strong) NSString *shippingzipcode;//邮编
@property (nonatomic,strong) NSString *shippingcontactphone;//联系电话
@property (nonatomic,strong) NSString *shippingcontactperson;//联系人名称

@property (nonatomic,strong) NSString *status;//?
@property (nonatomic,strong) NSString *paymentname;//支付方式
@property (nonatomic,strong) NSString *createdate;//订单创建时间
@property (nonatomic,strong) FSResource *resource;//商品图片资源
@property (nonatomic,strong) FSProdItemEntity *product;//商品信息？
@property (nonatomic,strong) NSString *memo;//订单备注

@property (nonatomic) BOOL canvoid;//是否可以取消订单
@property (nonatomic) int totalquantity;//商品数量

@end
