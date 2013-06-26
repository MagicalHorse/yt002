//
//  FSOrder.m
//  FashionShop
//
//  Created by HeQingshan on 13-6-22.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSOrder.h"

@implementation FSOrder

+(RKObjectMapping *)getRelationDataMap
{
    return [self getRelationDataMap:FALSE];
}

+(RKObjectMapping *)getRelationDataMap:(BOOL)isCollection
{
    
    RKObjectMapping *relationMapping = [RKObjectMapping mappingForClass:[self class]];
//    [relationMapping mapKeyPath:@"id" toAttribute:@"id"];
//    [relationMapping mapKeyPath:@"code" toAttribute:@"code"];
//    [relationMapping mapKeyPath:@"productid" toAttribute:@"productid"];
//    [relationMapping mapKeyPath:@"productname" toAttribute:@"productname"];
//    [relationMapping mapKeyPath:@"producttype" toAttribute:@"producttype"];
//    [relationMapping mapKeyPath:@"pass" toAttribute:@"pass"];
//    [relationMapping mapKeyPath:@"validstartdate" toAttribute:@"beginDate"];
//    [relationMapping mapKeyPath:@"validenddate" toAttribute:@"endDate"];
//    [relationMapping mapKeyPath:@"isused" toAttribute:@"isUsed"];
//    [relationMapping mapKeyPath:@"status" toAttribute:@"status"];
//    RKObjectMapping *prodRelationMap = [FSProdItemEntity getRelationDataMap];
//    [relationMapping mapKeyPath:@"product" toRelationship:@"product" withMapping:prodRelationMap];
//    RKObjectMapping *proRelationMap = [FSProItemEntity getRelationDataMap];
//    [relationMapping mapKeyPath:@"promotion" toRelationship:@"promotion" withMapping:proRelationMap];
    
    
    return relationMapping;
}

@end
