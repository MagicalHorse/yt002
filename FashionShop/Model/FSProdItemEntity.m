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
@synthesize brand;
@synthesize isCouponed;
@synthesize isFavored;

+(RKObjectMapping *) getRelationDataMap
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPathsToAttributes:@"id",@"id",@"name",@"title",@"favoritecount",@"favorTotal",@"couponcount",@"couponTotal",@"recommendedreason",@"descrip",@"isfavorited",@"isFavored",@"isreceived",@"isCouponed",nil];
    NSString *relationKeyPath = @"store";
    RKObjectMapping *storeRelationMap = [FSStore getRelationDataMap];
    [relationMap mapKeyPath:relationKeyPath toRelationship:@"store" withMapping:storeRelationMap];
    
    RKObjectMapping *resourceRelationMap = [FSResource getRelationDataMap];
    [relationMap mapKeyPath:@"resources" toRelationship:@"resource" withMapping:resourceRelationMap];
    RKObjectMapping *userRelationMap = [FSUser getRelationDataMap];
    [relationMap mapKeyPath:@"recommenduser" toRelationship:@"fromUser" withMapping:userRelationMap];
    
   // RKObjectMapping *couponRelationMap = [FSCoupon getRelationDataMap];
    //[relationMap mapKeyPath:@"coupon" toRelationship:@"coupons" withMapping:couponRelationMap];
    
    RKObjectMapping *commentRelationMap = [FSComment getRelationDataMap];
    [relationMap mapKeyPath:@"comment" toRelationship:@"comments" withMapping:commentRelationMap];
    
    RKObjectMapping *brandRelationMap = [FSBrand getRelationDataMap];
    [relationMap mapKeyPath:@"brand" toRelationship:@"brand" withMapping:brandRelationMap];
    
    return relationMap;
}

@end
