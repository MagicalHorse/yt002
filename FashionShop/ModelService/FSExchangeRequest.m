//
//  FSExchangeRequest.m
//  FashionShop
//
//  Created by HeQingshan on 13-5-7.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSExchangeRequest.h"

@implementation FSExchangeRequest
@synthesize routeResourcePath=_routeResourcePath;

-(void)setRouteResourcePath:(NSString *)aRouteResourcePath
{
    _routeResourcePath = aRouteResourcePath;
    if ([aRouteResourcePath isEqualToString:RK_REQUEST_STOREPROMOTION_LIST] ||
        [aRouteResourcePath isEqualToString:RK_REQUEST_STOREPROMOTION_DETAIL]) {
        [self setBaseURL:2];
    }
}

-(void) setMappingRequestAttribute:(RKObjectMapping *)map
{
    [map mapKeyPath:@"token" toAttribute:@"request.userToken"];
    [map mapKeyPath:@"page" toAttribute:@"request.nextPage"];
    [map mapKeyPath:@"pagesize" toAttribute:@"request.pageSize"];
    [map mapKeyPath:@"id" toAttribute:@"request.id"];
    [map mapKeyPath:@"storepromotionid" toAttribute:@"request.storePromotionId"];
    [map mapKeyPath:@"points" toAttribute:@"request.points"];
    [map mapKeyPath:@"identityno" toAttribute:@"request.identityNo"];
    [map mapKeyPath:@"type" toAttribute:@"request.type"];
    [map mapKeyPath:@"storeid" toAttribute:@"request.storeID"];
}

@end
