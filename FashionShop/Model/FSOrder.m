//
//  FSOrder.m
//  FashionShop
//
//  Created by HeQingshan on 13-6-22.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSOrder.h"

@implementation FSOrderInfo
@synthesize orderno,totalamount;
@synthesize needinvoice,invoicedetail,invoicesubject;
@synthesize canrma,rmas;
@synthesize shippingaddress,shippingcontactperson,shippingcontactphone,shippingfee,shippingno,shippingvianame,shippingzipcode;
@synthesize status,paymentname,createdate,resource,product,memo;
@synthesize canvoid,totalquantity;

+(RKObjectMapping *)getRelationDataMap
{
    return [self getRelationDataMap:FALSE];
}

+(RKObjectMapping *)getRelationDataMap:(BOOL)isCollection
{
    RKObjectMapping *relationMapping = [RKObjectMapping mappingForClass:[self class]];
    
    [relationMapping mapKeyPath:@"orderno" toAttribute:@"orderno"];
    [relationMapping mapKeyPath:@"totalamount" toAttribute:@"totalamount"];
    
    [relationMapping mapKeyPath:@"needinvoice" toAttribute:@"needinvoice"];
    [relationMapping mapKeyPath:@"invoicesubject" toAttribute:@"invoicesubject"];
    [relationMapping mapKeyPath:@"invoicedetail" toAttribute:@"invoicedetail"];
    
    [relationMapping mapKeyPath:@"canrma" toAttribute:@"canrma"];
    [relationMapping mapKeyPath:@"rmas" toAttribute:@"rmas"];
    
    [relationMapping mapKeyPath:@"shippingaddress" toAttribute:@"shippingaddress"];
    [relationMapping mapKeyPath:@"shippingno" toAttribute:@"shippingno"];
    [relationMapping mapKeyPath:@"shippingvianame" toAttribute:@"shippingvianame"];
    [relationMapping mapKeyPath:@"shippingfee" toAttribute:@"shippingfee"];
    [relationMapping mapKeyPath:@"shippingzipcode" toAttribute:@"shippingzipcode"];
    [relationMapping mapKeyPath:@"shippingcontactphone" toAttribute:@"shippingcontactphone"];
    [relationMapping mapKeyPath:@"shippingcontactperson" toAttribute:@"shippingcontactperson"];
    
    [relationMapping mapKeyPath:@"status" toAttribute:@"status"];
    [relationMapping mapKeyPath:@"paymentname" toAttribute:@"paymentname"];
    [relationMapping mapKeyPath:@"createdate" toAttribute:@"createdate"];
    [relationMapping mapKeyPath:@"memo" toAttribute:@"memo"];
    
    [relationMapping mapKeyPath:@"canvoid" toAttribute:@"canvoid"];
    [relationMapping mapKeyPath:@"totalquantity" toAttribute:@"totalquantity"];
    
    RKObjectMapping *relationMap = [FSResource getRelationDataMap];
    [relationMapping mapKeyPath:@"resource" toRelationship:@"resource" withMapping:relationMap];
    relationMap = [FSProdItemEntity getRelationDataMap];
    [relationMapping mapKeyPath:@"product" toRelationship:@"product" withMapping:relationMap];
    
    return relationMapping;
}

@end
