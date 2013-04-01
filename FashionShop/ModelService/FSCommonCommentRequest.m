
//
//  FSCommonCommentRequest.m
//  FashionShop
//
//  Created by gong yi on 12/13/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSCommonCommentRequest.h"
#import "FSModelManager.h"
#import "CommonHeader.h"
#import "RKJSONParserJSONKit.h"

@interface FSCommonCommentRequest()
{
    dispatch_block_t completeBlock;
    dispatch_block_t errorBlock;
    BOOL isClientRequest;
}

@end

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
@synthesize replyuserID;
@synthesize audioName;

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
    [map mapKeyPath:@"replyuser" toAttribute:@"request.replyuserID"];
}

- (void)upload:(dispatch_block_t)blockcomplete error:(dispatch_block_t)blockerror
{
    RKParams *params = [RKParams params];
    [params setValue:sourceid forParam:@"sourceid"];
    [params setValue:sourceType forParam:@"sourcetype"];
    [params setValue:nextPage forParam:@"page"];
    [params setValue:pageSize forParam:@"pagesize"];
    [params setValue:sort forParam:@"sort"];
    [params setValue:refreshTime forParam:@"refreshts"];
    
    [params setValue:userToken forParam:@"token"];
    [params setValue:comment forParam:@"content"];
    [params setValue:replyuserID forParam:@"replyuser"];
    
    if (audioName && ![audioName isEqualToString:@""]) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:audioName]) {
            NSData *data = [NSData dataWithContentsOfFile:audioName];
            if (data) {
                [params setData:data MIMEType:@"audio/x-m4a" forParam:@"audio.m4a"];
            }
        }
        else{
            NSLog(@"file not exist!");
        }
    }
    
    NSString *baseUrl =[self appendCommonRequestQueryPara:[FSModelManager sharedManager]];
    completeBlock = blockcomplete;
    errorBlock = blockerror;
    isClientRequest = true;
    [[RKClient sharedClient] post:baseUrl params:params delegate:self];
}

- (void)requestDidStartLoad:(RKRequest *)request
{
    
}

- (void)request:(RKRequest *)request didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
    if ([response isOK] && completeBlock && isClientRequest) {
        RKJSONParserJSONKit* parser = [[RKJSONParserJSONKit alloc] init];
        NSError *error = NULL;
        NSDictionary *result = [parser objectFromString:response.bodyAsString error:&error];
        if (!error && [[result objectForKey:@"statusCode"] intValue]==200) {
            completeBlock();
        }
        else
            errorBlock();
    } else if (errorBlock && isClientRequest){
        errorBlock();
    }
}

- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error
{
    if (errorBlock)
        errorBlock();
}

@end
