//
//  FSModelManager.h
//  FashionShop
//
//  Created by gong yi on 11/15/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestKit.h"
#import "FSConfigEntity.h"
#import "SinaWeibo.h"
#import "FSConfiguration.h"

@interface FSModelManager : NSObject

- (void) initModelManager;

+(RKObjectManager *) sharedManager;

+(FSModelManager *)sharedModelManager;


-(BOOL) isConfigLoaded;

-(void) forceReloadTags;
-(void) forceReloadBrands;
-(void) forceReloadStores;

-(BOOL) isLogined;

-(NSString *)loginToken;

-(SinaWeibo *)instantiateWeiboClient:(id<SinaWeiboDelegate>)delegate;

-(void)storeWeiboAuth:(SinaWeibo *)weibo;

-(void)removeWeiboAuthCache;

-(void)enqueueBackgroundBlock:(dispatch_block_t)block;

-(void)enqueueBackgoundOperation:(NSOperation *)operation;

-(void) clearCache;
@end
