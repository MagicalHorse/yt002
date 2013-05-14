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
@synthesize comments=_comments;
@synthesize tagId;
@synthesize isFavored;
@synthesize isCouponed;
@synthesize isProductBinded;
@synthesize isPublication;
@synthesize limitCount;
@synthesize height;
@synthesize promotionid;
@synthesize targetId;
@synthesize targetType;

+(RKObjectMapping *) getRelationDataMap
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPathsToAttributes:@"id",@"id",@"name",@"title",@"startdate",@"startDate",@"enddate",@"endDate",@"favoritecount",@"favorTotal",@"couponcount",@"couponTotal",@"description",@"descrip",@"isfavorited",@"isFavored",@"tagid",@"tagId",@"isproductbinded",@"isProductBinded",@"ispublication",@"isPublication",@"limitcount",@"limitCount",@"promotionid",@"promotionid",nil];
    
    [relationMap mapKeyPath:@"targetId" toAttribute:@"targetId"];
    [relationMap mapKeyPath:@"targetType" toAttribute:@"targetType"];
    
    NSString *relationKeyPath = @"store";
    RKObjectMapping *storeRelationMap = [FSStore getRelationDataMap];
    [relationMap mapKeyPath:relationKeyPath toRelationship:@"store" withMapping:storeRelationMap];
    
    RKObjectMapping *userRelationMap = [FSUser getRelationDataMap];
    [relationMap mapKeyPath:@"promotionuser" toRelationship:@"fromUser" withMapping:userRelationMap];
    RKObjectMapping *resourceRelationMap = [FSResource getRelationDataMap];
    [relationMap mapKeyPath:@"resources" toRelationship:@"resource" withMapping:resourceRelationMap];
    
    RKObjectMapping *commentRelationMap = [FSComment getRelationDataMap];
    [relationMap mapKeyPath:@"comment" toRelationship:@"comments" withMapping:commentRelationMap];
        return relationMap;
}

-(NSMutableArray *)comments
{
    if (!_comments)
        _comments= [@[] mutableCopy];
    return _comments;
}

@end
