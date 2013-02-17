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

@synthesize id;
@synthesize store;
@synthesize title;
@synthesize type;
@synthesize descrip;
@synthesize fromUser;
@synthesize inDate;
@synthesize couponTotal,favorTotal;
@synthesize resource;
@synthesize coupons;
@synthesize comments;
@synthesize promotions;
@synthesize brand;
@synthesize price;
@synthesize isCouponed;
@synthesize isFavored;
@synthesize hasPromotion;

+(RKObjectMapping *) getRelationDataMap
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPathsToAttributes:@"id",@"id",@"name",@"title",@"favoritecount",@"favorTotal",@"couponcount",@"couponTotal",@"description",@"descrip",@"isfavorited",@"isFavored",@"isreceived",@"isCouponed",@"price",@"price",nil];
    NSString *relationKeyPath = @"store";
    RKObjectMapping *storeRelationMap = [FSStore getRelationDataMap];
    [relationMap mapKeyPath:relationKeyPath toRelationship:@"store" withMapping:storeRelationMap];
    
    RKObjectMapping *resourceRelationMap = [FSResource getRelationDataMap];
    [relationMap mapKeyPath:@"resources" toRelationship:@"resource" withMapping:resourceRelationMap];
    RKObjectMapping *userRelationMap = [FSUser getRelationDataMap];
    [relationMap mapKeyPath:@"recommenduser" toRelationship:@"fromUser" withMapping:userRelationMap];
    
    RKObjectMapping *promotionRelationMap = [FSProItemEntity getRelationDataMap];
    [relationMap mapKeyPath:@"promotions" toRelationship:@"promotions" withMapping:promotionRelationMap];
    
    RKObjectMapping *commentRelationMap = [FSComment getRelationDataMap];
    [relationMap mapKeyPath:@"comment" toRelationship:@"comments" withMapping:commentRelationMap];
    
    RKObjectMapping *brandRelationMap = [FSBrand getRelationDataMap];
    [relationMap mapKeyPath:@"brand" toRelationship:@"brand" withMapping:brandRelationMap];
    
    return relationMap;
}

-(BOOL)hasPromotion
{
    if (!promotions) {
        return NO;
    }
    if (promotions.count > 0) {
        for (FSProItemEntity *item in promotions) {
            if (item.isPublication) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

@end
