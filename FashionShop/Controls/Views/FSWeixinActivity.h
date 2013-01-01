//
//  FSWeixinActivity.h
//  FashionShop
//
//  Created by gong yi on 11/21/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "FSShareView.h"

@interface FSWeixinActivity : FSUIActivity<WXApiDelegate>


@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) UIImage *img;


+(FSWeixinActivity *)sharedInstance;

-(BOOL)handleOpenUrl:(NSURL *)url;
@end
