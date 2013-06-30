//
//  FSPurchase.m
//  FashionShop
//
//  Created by HeQingshan on 13-6-28.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSPurchase.h"

@implementation FSPurchase
@synthesize id;
@synthesize name;
@synthesize description;
@synthesize price;
@synthesize originprice;
@synthesize properties;
@synthesize rmapolicy;
@synthesize supportpayments;
@synthesize productImage;
@synthesize sizeImage;

//amount info
@synthesize totalamount,totalfee,totalpoints,totalquantity,extendprice;

+(RKObjectMapping *)getRelationDataMap
{
    RKObjectMapping *relationMapping = [RKObjectMapping mappingForClass:[self class]];
    
    [relationMapping mapKeyPath:@"id" toAttribute:@"id"];
    [relationMapping mapKeyPath:@"name" toAttribute:@"name"];
    [relationMapping mapKeyPath:@"description" toAttribute:@"description"];
    [relationMapping mapKeyPath:@"price" toAttribute:@"price"];
    [relationMapping mapKeyPath:@"originprice" toAttribute:@"originprice"];
    [relationMapping mapKeyPath:@"rmapolicy" toAttribute:@"rmapolicy"];
    
    RKObjectMapping *relationMap = [FSResource getRelationDataMap];
    [relationMapping mapKeyPath:@"resource" toRelationship:@"productImage" withMapping:relationMap];
    
    relationMap = [FSResource getRelationDataMap];
    [relationMapping mapKeyPath:@"dimension" toRelationship:@"sizeImage" withMapping:relationMap];
    
    relationMap = [FSPurchasePropertiesItem getRelationDataMap];
    [relationMapping mapKeyPath:@"properties" toRelationship:@"properties" withMapping:relationMap];
    
    relationMap = [FSPurchaseSPaymentItem getRelationDataMap];
    [relationMapping mapKeyPath:@"supportpayments" toRelationship:@"supportpayments" withMapping:relationMap];
    
    //请求计算金额返回数据
    [relationMapping mapKeyPath:@"totalamount" toAttribute:@"totalamount"];
    [relationMapping mapKeyPath:@"totalfee" toAttribute:@"totalfee"];
    [relationMapping mapKeyPath:@"totalpoints" toAttribute:@"totalpoints"];
    [relationMapping mapKeyPath:@"totalquantity" toAttribute:@"totalquantity"];
    [relationMapping mapKeyPath:@"extendprice" toAttribute:@"extendprice"];
    
    return relationMapping;
}

@end

@implementation FSPurchasePropertiesItem
@synthesize propertyid;
@synthesize propertyname;
@synthesize valueid;
@synthesize valuename;
@synthesize values;

+(RKObjectMapping *)getRelationDataMap
{
    static int index = 0;
    
    RKObjectMapping *relationMapping = [RKObjectMapping mappingForClass:[self class]];
    
    if (index == 0) {
        [relationMapping mapKeyPath:@"propertyid" toAttribute:@"propertyid"];
        [relationMapping mapKeyPath:@"propertyname" toAttribute:@"propertyname"];
    }
    else {
        [relationMapping mapKeyPath:@"valueid" toAttribute:@"valueid"];
        [relationMapping mapKeyPath:@"valuename" toAttribute:@"valuename"];
    }
    
    if (++index <= 1) {
        RKObjectMapping *relationMap = [FSPurchasePropertiesItem getRelationDataMap];
        [relationMapping mapKeyPath:@"values" toRelationship:@"values" withMapping:relationMap];
    }
    else{
        index = 0;
    }
    
    return relationMapping;
}

@end

@implementation FSPurchaseSPaymentItem
@synthesize code,name;

+(RKObjectMapping *)getRelationDataMap
{
    RKObjectMapping *relationMapping = [RKObjectMapping mappingForClass:[self class]];
    [relationMapping mapKeyPath:@"code" toAttribute:@"code"];
    [relationMapping mapKeyPath:@"name" toAttribute:@"name"];
    
    return relationMapping;
}

@end

@implementation FSPurchaseForUpload
@synthesize productid,desc,quantity,needinvoice,invoicetitle,invoicedetail,telephone,memo,payment,address,properies;

-(id)init
{
    self = [super init];
    if (self) {
        productid = -1;
        quantity = -1;
        needinvoice = NO;
    }
    return self;
}

-(void)reset
{
    productid = -1;
    desc = nil;
    quantity = -1;
    needinvoice = NO;
    invoicetitle = nil;
    invoicedetail = nil;
    telephone = nil;
    memo = nil;
    payment = nil;
    address = nil;
    [properies removeAllObjects];
    properies = nil;
}

@end