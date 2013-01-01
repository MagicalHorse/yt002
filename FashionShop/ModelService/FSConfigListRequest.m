//
//  FSConfigListRequest.m
//  FashionShop
//
//  Created by gong yi on 11/20/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSConfigListRequest.h"



@implementation FSConfigListRequest

@synthesize longit;
@synthesize lantit;
@synthesize routeResourcePath;

-(void) setMappingRequestAttribute:(RKObjectMapping *)map
{
    [map mapKeyPath:@"lng" toAttribute:@"request.longit"];
    [map mapKeyPath:@"lat" toAttribute:@"request.lantit"];
}
@end
