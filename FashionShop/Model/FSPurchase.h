//
//  FSPurchase.h
//  FashionShop
//
//  Created by HeQingshan on 13-6-28.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSModelBase.h"
#import "FSResource.h"
#import "FSAddress.h"

#define Purchase_Count_Properties_Tag -123

@interface FSPurchase : FSModelBase

@property (nonatomic) int id;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *description;
@property (nonatomic) float price;
@property (nonatomic) float originprice;
@property (nonatomic,strong) NSMutableArray *properties;
@property (nonatomic,strong) NSString *rmapolicy;//商家信誉
@property (nonatomic,strong) NSMutableArray *supportpayments;//支持的支付方式
@property (nonatomic,strong) NSMutableArray *invoicedetails;//支持的发票明细数组
@property (nonatomic,strong) FSResource *productImage;
@property (nonatomic,strong) FSResource *sizeImage;

//amount info
@property (nonatomic) float totalfee;
@property (nonatomic) int totalpoints;
@property (nonatomic) float extendprice;
@property (nonatomic) int totalquantity;
@property (nonatomic) float totalamount;

//other no map
@property (nonatomic,strong) NSString *addressDetailDesc;
@property (nonatomic,strong) NSString *paywayDesc;
@property (nonatomic,strong) NSString *voiceDesc;
@property (nonatomic,strong) NSString *orderNoteDesc;
@property (nonatomic,strong) NSString *phoneDesc;

@end

@interface FSPurchasePropertiesItem : FSModelBase

@property (nonatomic) int propertyid;
@property (nonatomic,strong) NSString *propertyname;
@property (nonatomic) int valueid;
@property (nonatomic,strong) NSString *valuename;
@property (nonatomic,strong) NSMutableArray *values;
@property (nonatomic) BOOL isChecked;//是否选中

@end

@interface FSPurchaseSPaymentItem : FSModelBase

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *name;

@end

@interface FSPurchaseForUpload : NSObject

@property (nonatomic) int productid;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic) int quantity;
@property (nonatomic) BOOL needinvoice;
@property (nonatomic, strong) NSString *invoicetitle;
@property (nonatomic, strong) NSString *invoicedetail;
@property (nonatomic, strong) NSString *telephone;
@property (nonatomic, strong) NSString *memo;
@property (nonatomic, strong) FSPurchaseSPaymentItem *payment;
@property (nonatomic, strong) FSAddress *address;
@property (nonatomic, strong) NSMutableArray *properies;

-(void)reset;

@end
