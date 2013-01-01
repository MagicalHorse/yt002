//
//  FSUser.m
//  FashionShop
//
//  Created by gong yi on 11/16/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSUser.h"
#import "FSLocalPersist.h"
#import "FSCoupon.h"
#import "FSModelManager.h"


#define LOCAL_STORE_USER_KEY @"useraccountprofile"
#define LOCAL_STORE_USER_LOGIN_TOKEN @"userlogintoken"
#define LOCAL_STORE_DEVICE_TOKEN @"useraccountdevicetoken"

@implementation FSUser

@synthesize uid;
@synthesize uToken;
@synthesize nickie;
@synthesize phone;
@synthesize likeTotal;
@synthesize fansTotal;
@synthesize pointsTotal;
@synthesize userLevelId;
@synthesize userLevelName;
@synthesize thumnail;
@synthesize isLiked;
@synthesize couponsTotal;
@synthesize coupons;



+(RKObjectMapping *) getRelationDataMap
{
    return [self getRelationDataMap:false];
}


+(RKObjectMapping *) getRelationDataMap:(BOOL)isCollection
{
    RKObjectMapping *relationMap = [RKObjectMapping mappingForClass:[self class]];
    [relationMap mapKeyPathsToAttributes:@"nickname",@"nickie",@"level",@"userLevelId",@"pointtotal",@"pointsTotal",@"coupontotal",@"couponsTotal",@"token",@"uToken",@"id",@"uid",@"likecount",@"likeTotal",@"likedcount",@"fansTotal",@"phone",@"phone",@"logo",@"thumnail",@"isliked",@"isLiked",nil];
   // RKObjectMapping *couponRelationMap = [FSCoupon getRelationDataMap];
   // [relationMap mapKeyPath:@"coupons" toRelationship:@"coupons" withMapping:couponRelationMap];
    return relationMap;
}


+ (void) removeUserProfile
{
    [[FSLocalPersist sharedPersist] removeObjectInMemory:LOCAL_STORE_USER_KEY];
    [[FSLocalPersist sharedPersist] removeObjectInDisk:LOCAL_STORE_USER_LOGIN_TOKEN];
 
    
}


+(FSUser *) localProfile
{
    return [[FSLocalPersist sharedPersist] objectInMemory:LOCAL_STORE_USER_KEY];
}

+(NSString *) localLoginToken
{
    return [[FSLocalPersist sharedPersist] objectInDisk:LOCAL_STORE_USER_LOGIN_TOKEN];
}


+(NSString *) localDeviceToken
{
   return [[FSLocalPersist sharedPersist] objectInDisk:LOCAL_STORE_DEVICE_TOKEN];
}


+(void) saveDeviceToken:(NSString *)device
{
    [[FSLocalPersist sharedPersist] setObjectInDisk:device
                toKey:LOCAL_STORE_DEVICE_TOKEN];

}

- (void) save
{
    [[FSLocalPersist sharedPersist] setObjectInMemory:self toKey:LOCAL_STORE_USER_KEY];
    [[FSLocalPersist sharedPersist] setObjectInDisk:self.uToken toKey:LOCAL_STORE_USER_LOGIN_TOKEN];

}


-(NSURL *)thumnailUrl
{
    if (!thumnail)
        return nil;
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@_50x50.jpg",thumnail]];
}

@end
