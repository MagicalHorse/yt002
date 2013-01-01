//
//  FSProItemEntity.m
//  FashionShop
//
//  Created by gong yi on 11/17/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSProItemEntity.h"
#import "FSCoupon.h"
#import "FSComment.h"

@implementation FSProItemEntity

@synthesize id;
@synthesize startDate;
@synthesize store;
@synthesize title;
@synthesize type;
@synthesize descrip;
@synthesize endDate;
@synthesize proImgs;
@synthesize fromUser;
@synthesize inDate;
@synthesize couponTotal,favorTotal;
@synthesize resource;
@synthesize coupons;
@synthesize comments;
@synthesize isFavored;
@synthesize isCouponed;

+(RKObjectMapping *) getRelationDataMap
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPathsToAttributes:@"id",@"id",@"name",@"title",@"startdate",@"startDate",@"enddate",@"endDate",@"favoritecount",@"favorTotal",@"couponcount",@"couponTotal",@"description",@"descrip",@"isfavorited",@"isFavored",nil];
    NSString *relationKeyPath = @"store";
    RKObjectMapping *storeRelationMap = [FSStore getRelationDataMap];
    [relationMap mapKeyPath:relationKeyPath toRelationship:@"store" withMapping:storeRelationMap];
    
    RKObjectMapping *userRelationMap = [FSUser getRelationDataMap];
    [relationMap mapKeyPath:@"promotionuser" toRelationship:@"fromUser" withMapping:userRelationMap];
    RKObjectMapping *resourceRelationMap = [FSResource getRelationDataMap];
    [relationMap mapKeyPath:@"resources" toRelationship:@"resource" withMapping:resourceRelationMap];
    
   // RKObjectMapping *couponRelationMap = [FSCoupon getRelationDataMap];
   // [relationMap mapKeyPath:@"coupon" toRelationship:@"coupons" withMapping:couponRelationMap];
    RKObjectMapping *commentRelationMap = [FSComment getRelationDataMap];
    [relationMap mapKeyPath:@"comment" toRelationship:@"comments" withMapping:commentRelationMap];

    return relationMap;
}

@end
