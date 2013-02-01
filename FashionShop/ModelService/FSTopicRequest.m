//
//  FSTopicRequest.m
//  FashionShop
//
//  Created by HeQingshan on 13-1-31.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "FSTopicRequest.h"

@implementation FSTopicRequest
@synthesize nextPage;
@synthesize pageSize;
@synthesize filterType;
@synthesize previousLatestDate;
//@synthesize requestType = _requestType;
//@synthesize requestTypeName;

-(NSString*)routeResourcePath
{
    return RK_REQUEST_TOPIC_LIST;
}

//-(void)setRequestType:(int)requestType
//{
//    _requestType = requestType;
//    if (_requestType ==0 )
//        requestTypeName = @"refresh";
//}

-(void)setMappingRequestAttribute:(RKObjectMapping *)map
{
    [map mapKeyPath:@"page" toAttribute:@"request.nextPage"];
    [map mapKeyPath:@"pagesize" toAttribute:@"request.pageSize"];
    [map mapKeyPath:@"sort" toAttribute:@"request.filterType"];
    [map mapKeyPath:@"refreshts" toAttribute:@"previousLatestDate"];
//    [map mapKeyPath:@"type" toAttribute:@"request.requestTypeName"];
}

@end
