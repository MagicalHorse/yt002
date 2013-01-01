//
//  FSCommonCommentRequest.m
//  FashionShop
//
//  Created by gong yi on 12/13/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSCommonCommentRequest.h"

@implementation FSCommonCommentRequest

@synthesize id;
@synthesize sourceid;
@synthesize sourceType;
@synthesize comment;
@synthesize userId;
@synthesize refreshTime;
@synthesize pageSize;
@synthesize nextPage;
@synthesize sort;
@synthesize userToken;
@synthesize routeResourcePath;

-(void) setMappingRequestAttribute:(RKObjectMapping *)map
{
    [map mapKeyPath:@"id" toAttribute:@"request.id"];
    [map mapKeyPath:@"sourceid" toAttribute:@"request.sourceid"];
    [map mapKeyPath:@"sourcetype" toAttribute:@"request.sourceType"];
    [map mapKeyPath:@"page" toAttribute:@"request.nextPage"];
    [map mapKeyPath:@"pagesize" toAttribute:@"request.pageSize"];
    [map mapKeyPath:@"sort" toAttribute:@"request.sort"];
    [map mapKeyPath:@"refreshts" toAttribute:@"request.refreshTime"];
    [map mapKeyPath:@"token" toAttribute:@"request.userToken"];
    [map mapKeyPath:@"content" toAttribute:@"request.comment"];
    
    
}

@end
