//
//  FSEntityRequestBase.m
//  FashionShop
//
//  Created by gong yi on 11/16/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSEntityRequestBase.h"
#import "CommonHeader.h"
#import "FSModelManager.h"
#import "FSModelBase.h"
#import "FSCoreModelBase.h"


@interface FSEntityRequestBase()
{
  __strong  FSRequestLoadComplete requestCompleteCallback;
}

@end
@implementation FSEntityRequestBase
@dynamic routeResourcePath,requestMethod;
@synthesize isCollection=_isCollection;
@synthesize rootKeyPath = _rootKeyPath;

-(NSString *)rootKeyPath
{
    if (!_rootKeyPath)
        _rootKeyPath = @"data";
    return _rootKeyPath;
}

-(NSString *) appendCommonRequestQueryPara:(RKObjectManager *)manager{
    NSMutableDictionary *queryParams = [@{} mutableCopy];
    CommonHeader *comHeader = [[CommonHeader alloc] init];
    [queryParams addEntriesFromDictionary:[comHeader toQueryDic]];
    RKURL *URL = [RKURL URLWithBaseURL:[manager baseURL] resourcePath:self.routeResourcePath queryParameters:queryParams];
    
    return [NSString stringWithFormat:@"%@?%@", [URL resourcePath], [URL query]]  ;

}

- (void) setMappingRequestAttribute:(RKObjectMapping *)map{

    
}


-(void) send:(Class)responseClass withRequest:(FSEntityRequestBase *)request completeCallBack:(FSRequestLoadComplete)completeCallback
{
    RKObjectManager *innerManager = [FSModelManager sharedManager];
   
    FSEntityBase *entityObject = [[FSEntityBase alloc] init];
    entityObject.request = request;
    entityObject.dataClass = responseClass;
    RKObjectMapping *responseMap = [RKObjectMapping mappingForClass:[entityObject class]];
    [entityObject mapRequestReponse:responseMap toManager:innerManager];
    NSString *url = [request appendCommonRequestQueryPara:innerManager];
        requestCompleteCallback = completeCallback;
    //make sure the request is sequential , or there may have some nega impact here
    [[FSModelManager sharedModelManager] enqueueBackgroundBlock:^{
        [innerManager sendObject:entityObject toResourcePath:url usingBlock:^(RKObjectLoader *loader) {
            loader.method = RKRequestMethodPOST;
            loader.delegate = self;
            loader.objectMapping = responseMap;
            loader.serializationMapping = entityObject.requestMap;
            
        }];
    }];
}

- (void) parseResponseHeader:(FSEntityBase *)response
{
    NSString *statusCode = response.statusCode;
    
    if ([statusCode isEqualToString:@"200" ])
        response.isSuccess = true;
    else if (statusCode!=nil &&
        statusCode.length>0)
    {
        if ([statusCode hasPrefix:@"4"]) //unauthorize
        {
            response.errorType = UnAuthorized;
            response.errorDescrip = response.message;
        } else if([statusCode hasPrefix:@"5"])
        {
            response.errorDescrip = response.message;
            response.errorType = ServerInternal;
        }
        response.isSuccess = false;
    } else
    {
        response.isSuccess = false;
        response.errorType = Other;
    }
  
}


#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
   if (requestCompleteCallback)
   {
       FSEntityBase *response = [objects lastObject];
       [self parseResponseHeader:response];
       requestCompleteCallback(response);
   }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    if (requestCompleteCallback)
    {
        
        FSEntityBase *response = [[FSEntityBase alloc] init];
        response.isSuccess = false;
        response.errorType = NetworkError;
        response.errorDescrip = @"Network failed!";
        requestCompleteCallback(response);
    }
}

@end
