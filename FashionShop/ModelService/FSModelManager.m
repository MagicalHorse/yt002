//
//  FSModelManager.m
//  FashionShop
//
//  Created by gong yi on 11/15/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import "FSModelManager.h"
#import "RestKit.h"
#import "FSConfigListRequest.h"
#import "FSLocalPersist.h"
#import "FSCoreTag.h"
#import "SDImageCache.h"
#import "FSLocationManager.h"
#import "FSCoreStore.h"
#import "FSCoreBrand.h"

@interface FSModelManager()
{
    BOOL _isConfigLoaded;
    NSOperationQueue *_asyncQueue;
    
}

@end
static FSModelManager *_modelManager;
@implementation FSModelManager

- (void) initModelManager{
    //[RKManagedObjectStore deleteStoreInApplicationDataDirectoryWithFilename:@"FSShop.sqlite"];
    RKURL *baseURL = [RKURL URLWithBaseURLString:REST_API_URL];
    RKObjectManager *objectManager = [RKObjectManager objectManagerWithBaseURL:baseURL];
    objectManager.client.baseURL = baseURL;
    [RKManagedObjectMapping addDefaultDateFormatterForString:@"yyyy-MM-dd'T'HH:mm:ssZ" inTimeZone:nil];
    
    RKManagedObjectStore *objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"FSShop.sqlite"];
    objectManager.objectStore = objectStore;
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);

}

-(id) init
{
    self = [super init];
    if (self)
    {
        _asyncQueue = [[NSOperationQueue alloc] init];
        [_asyncQueue setMaxConcurrentOperationCount:2];
        [self initModelManager];
    }
    return self;
}


+(RKObjectManager *)sharedManager{
    return  [RKObjectManager sharedManager];
    
}

+(FSModelManager *)sharedModelManager
{
    if (!_modelManager)
    {
        _modelManager = [[FSModelManager alloc] init];
        [_modelManager initConfig];
        //[[FSModelManager sharedModelManager] removeWeiboAuthCache];
      
    }
    return _modelManager;
}


-(BOOL) isConfigLoaded
{
    return _isConfigLoaded;
}

-(BOOL) isLogined
{
    NSString *loginToken = [FSUser localLoginToken];

    if (loginToken!=nil && loginToken.length>0)
    {
        return true;
    }
    else
    {
        return false;
    }
}



-(void)enqueueBackgroundOperation:(NSOperation *)operation{
    [_asyncQueue addOperation:operation];
}

-(void)enqueueBackgroundBlock:(dispatch_block_t)block{
    [_asyncQueue addOperationWithBlock:block];
}


-(NSString *) loginToken
{
    return [FSUser localLoginToken];
}
-(void) forceReloadTags
{
    [self enqueueBackgroundBlock:^{
        FSConfigListRequest *request = [[FSConfigListRequest alloc] init];
        request.routeResourcePath = RK_REQUEST_CONFIG_TAG_ALL;
        [request send:[FSCoreTag class] withRequest:request completeCallBack:nil];
    }];

}
-(void) forceReloadBrands
{
    [self enqueueBackgroundBlock:^{
        
        FSConfigListRequest *request = [[FSConfigListRequest alloc] init];
        request.routeResourcePath = RK_REQUEST_CONFIG_BRAND_ALL;
        [request send:[FSCoreBrand class] withRequest:request completeCallBack:nil];
    }];
}
-(void) forceReloadStores
{
    [self enqueueBackgroundBlock:^() {
        FSConfigListRequest *request = [[FSConfigListRequest alloc] init];
        request.longit =[NSNumber numberWithFloat:[FSLocationManager sharedLocationManager].currentCoord.longitude];
        request.lantit =[NSNumber numberWithFloat:[FSLocationManager sharedLocationManager].currentCoord.latitude];
        request.routeResourcePath = RK_REQUEST_CONFIG_STORE_ALL;
        [request send:[FSCoreStore class] withRequest:request completeCallBack:nil
         ];
        
        
    }];
}

-(void) initConfig
{
    [self forceReloadTags];
    [self forceReloadBrands];
    [self forceReloadStores];

}

-(SinaWeibo *)instantiateWeiboClient:(id<SinaWeiboDelegate>)delegate
{
   SinaWeibo * _weibo = [[SinaWeibo alloc] initWithAppKey:SINA_WEIBO_APP_KEY appSecret:SINA_WEIBO_APP_SECRET_KEY appRedirectURI:SINA_WEIBO_APP_REDIRECT_URI andDelegate:delegate];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
        if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
        {
            _weibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
            _weibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
            _weibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
        }
    return _weibo;
}

-(void)storeWeiboAuth:(SinaWeibo *)weibo
{
    
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              weibo.accessToken, @"AccessTokenKey",
                              weibo.expirationDate, @"ExpirationDateKey",
                              weibo.userID, @"UserIDKey",
                              weibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)removeWeiboAuthCache
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];

}

-(void)clearCache
{
    [self enqueueBackgroundBlock:^() {
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDisk];
    }];

}

@end
