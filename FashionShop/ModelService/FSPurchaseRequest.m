//
//  FSPurchaseRequest.m
//  FashionShop
//
//  Created by HeQingshan on 13-6-28.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSPurchaseRequest.h"

@implementation FSPurchaseRequest
@synthesize id,uToken,quantity;
@synthesize routeResourcePath=_routeResourcePath;

-(void)setRouteResourcePath:(NSString *)aRouteResourcePath
{
    _routeResourcePath = aRouteResourcePath;
}

-(void) setMappingRequestAttribute:(RKObjectMapping *)map
{
    [map mapKeyPath:@"token" toAttribute:@"request.uToken"];
    
    if ([_routeResourcePath isEqualToString:RK_REQUEST_PROD_BUY_INFO]) {
        [map mapKeyPath:@"productid" toAttribute:@"request.id"];
    }
    else if ([_routeResourcePath isEqualToString:RK_REQUEST_PROD_BUY_AMOUNT]) {
        [map mapKeyPath:@"productid" toAttribute:@"request.id"];
        [map mapKeyPath:@"quantity" toAttribute:@"request.quantity"];
    }
    else if ([_routeResourcePath isEqualToString:RK_REQUEST_PROD_ORDER]) {
        [map mapKeyPath:@"order" toAttribute:@"request.order"];
    }
    else if ([_routeResourcePath isEqualToString:RK_REQUEST_ORDER_LIST]) {
        [map mapKeyPath:@"type" toAttribute:@"request.type"];
        [map mapKeyPath:@"page" toAttribute:@"request.nextPage"];
        [map mapKeyPath:@"pagesize" toAttribute:@"request.pageSize"];
    }
    else if([_routeResourcePath isEqualToString:RK_REQUEST_ORDER_DETAIL] || [_routeResourcePath isEqualToString:RK_REQUEST_ORDER_RMA]) {
        [map mapKeyPath:@"orderno" toAttribute:@"request.orderno"];
    }
}

@end
