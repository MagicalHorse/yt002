//
//  FSProdItemEntity.m
//  FashionShop
//
//  Created by gong yi on 11/24/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProdItemEntity.h"
#import "FSResource.h"
#import "FSCoupon.h"
#import "FSComment.h"
#import "FSProItemEntity.h"

@implementation FSProdItemEntity

//product detail need attributes
@synthesize id;
@synthesize title;
@synthesize couponTotal;
@synthesize favorTotal;
@synthesize descrip;
@synthesize price;
@synthesize unitPrice;
@synthesize is4sale;
@synthesize contactPhone;

//@synthesize recommendUser_id;
//@synthesize recommendedReason;
//@synthesize unitPrice;
//@synthesize shareCount;

@synthesize brand;
@synthesize fromUser;
@synthesize resource;
@synthesize store;
@synthesize promotions;
//@synthesize tag;

//other need attributes
@synthesize brandDesc;
@synthesize promotionFlag;
@synthesize isCouponed;
@synthesize isFavored;

/*
@synthesize type;
@synthesize inDate;

@synthesize coupons;
@synthesize comments;
@synthesize hasPromotion;
 */

+(RKObjectMapping *) getRelationDataMap
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    
    //product detail need attributes
    [relationMap mapKeyPath:@"id" toAttribute:@"id"];
    [relationMap mapKeyPath:@"name" toAttribute:@"title"];
    [relationMap mapKeyPath:@"favoritecount" toAttribute:@"favorTotal"];
    [relationMap mapKeyPath:@"couponcount" toAttribute:@"couponTotal"];
    [relationMap mapKeyPath:@"description" toAttribute:@"descrip"];
    [relationMap mapKeyPath:@"price" toAttribute:@"price"];
    [relationMap mapKeyPath:@"unitprice" toAttribute:@"unitPrice"];
    [relationMap mapKeyPath:@"is4sale" toAttribute:@"is4sale"];
    [relationMap mapKeyPath:@"contactphone" toAttribute:@"contactPhone"];
    
//    [relationMap mapKeyPath:@"recommenduser_id" toAttribute:@"recommendUser_id"];
//    [relationMap mapKeyPath:@"recommendedreason" toAttribute:@"recommendedReason"];
//    [relationMap mapKeyPath:@"unitprice" toAttribute:@"unitPrice"];
//    [relationMap mapKeyPath:@"sharecount" toAttribute:@"shareCount"];
    
    RKObjectMapping *brandRelationMap = [FSBrand getRelationDataMap];
    [relationMap mapKeyPath:@"brand" toRelationship:@"brand" withMapping:brandRelationMap];
    
    RKObjectMapping *userRelationMap = [FSUser getRelationDataMap];
    [relationMap mapKeyPath:@"recommenduser" toRelationship:@"fromUser" withMapping:userRelationMap];
    
    RKObjectMapping *resourceRelationMap = [FSResource getRelationDataMap];
    [relationMap mapKeyPath:@"resources" toRelationship:@"resource" withMapping:resourceRelationMap];
    
    RKObjectMapping *storeRelationMap = [FSStore getRelationDataMap];
    [relationMap mapKeyPath:@"store" toRelationship:@"store" withMapping:storeRelationMap];
    
    RKObjectMapping *promotionRelationMap = [FSProItemEntity getRelationDataMap];
    [relationMap mapKeyPath:@"promotions" toRelationship:@"promotions" withMapping:promotionRelationMap];
    
//    RKObjectMapping *commentRelationMap = [FSTag getRelationDataMap];
//    [relationMap mapKeyPath:@"tag" toRelationship:@"tag" withMapping:commentRelationMap];
    
    //other need attributes
    [relationMap mapKeyPath:@"branddesc" toAttribute:@"brandDesc"];
    [relationMap mapKeyPath:@"promotionFlag" toAttribute:@"promotionFlag"];
    [relationMap mapKeyPath:@"isfavored" toAttribute:@"isFavored"];
    [relationMap mapKeyPath:@"ifcancoupon" toAttribute:@"isCouponed"];
//    [relationMap mapKeyPath:@"isfavorited" toAttribute:@"isFavored"];
//    [relationMap mapKeyPath:@"isreceived" toAttribute:@"isCouponed"];
    
    return relationMap;
}

-(BOOL)hasPromotion
{
    if (!promotions) {
        return NO;
    }
    if (promotions.count > 0) {
        return YES;
    }
    return NO;
}

@end
