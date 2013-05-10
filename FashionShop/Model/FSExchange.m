//
//  FSExchange.m
//  FashionShop
//
//  Created by HeQingshan on 13-5-8.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSExchange.h"
#import "FSCommon.h"

@implementation FSExchange
@synthesize id,name,desc,createdDate;
@synthesize activeStartDate,activeEndDate;
@synthesize couponStartDate,couponEndDate;
@synthesize notice,minPoints,usageNotice,inScopeNotice;
@synthesize unitPerPoints,amount,rule,exchangeRuleMessage;

@synthesize rules,inscopenotices;

+(RKObjectMapping *)getRelationDataMap
{
    return [self getRelationDataMap:FALSE];
}

+(RKObjectMapping *)getRelationDataMap:(BOOL)isCollection
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPath:@"id" toAttribute:@"id"];
    [relationMap mapKeyPath:@"name" toAttribute:@"name"];
    [relationMap mapKeyPath:@"des" toAttribute:@"desc"];
    [relationMap mapKeyPath:@"createddate" toAttribute:@"createdDate"];
    [relationMap mapKeyPath:@"activestartdate" toAttribute:@"activeStartDate"];
    [relationMap mapKeyPath:@"activeenddate" toAttribute:@"activeEndDate"];
    [relationMap mapKeyPath:@"couponstartdate" toAttribute:@"couponStartDate"];
    [relationMap mapKeyPath:@"couponenddate" toAttribute:@"couponEndDate"];
    [relationMap mapKeyPath:@"notice" toAttribute:@"notice"];
    [relationMap mapKeyPath:@"minpoints" toAttribute:@"minPoints"];
    [relationMap mapKeyPath:@"usagenotice" toAttribute:@"usageNotice"];
    [relationMap mapKeyPath:@"inscopenotice" toAttribute:@"inScopeNotice"];
    [relationMap mapKeyPath:@"exchangerulemessage" toAttribute:@"exchangeRuleMessage"];
    [relationMap mapKeyPath:@"rule" toAttribute:@"rule"];
    [relationMap mapKeyPath:@"unitperpoints" toAttribute:@"unitPerPoints"];
    [relationMap mapKeyPath:@"Amount" toAttribute:@"amount"];
    
    RKObjectMapping *resourceRelationMap = [FSCommon getRelationDataMap];
    [relationMap mapKeyPath:@"inscopenotice" toRelationship:@"inscopenotices" withMapping:resourceRelationMap];
    [relationMap mapKeyPath:@"rule" toRelationship:@"rules" withMapping:resourceRelationMap];
    
    return relationMap;
}

@end

@implementation FSExchangeSuccess

+(RKObjectMapping *)getRelationDataMap
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPath:@"Points" toAttribute:@"points"];
    [relationMap mapKeyPath:@"Amount" toAttribute:@"amount"];
    [relationMap mapKeyPath:@"Id" toAttribute:@"storeProId"];
    [relationMap mapKeyPath:@"Code" toAttribute:@"giftCode"];
    [relationMap mapKeyPath:@"Exclude" toAttribute:@"exclude"];
    [relationMap mapKeyPath:@"StoreName" toAttribute:@"storeName"];
    [relationMap mapKeyPath:@"ValidEndDate" toAttribute:@"validEndDate"];
    [relationMap mapKeyPath:@"ValidStartDate" toAttribute:@"validStartDate"];
    [relationMap mapKeyPath:@"CreateDate" toAttribute:@"createDate"];
    
    return relationMap;
}

@end
