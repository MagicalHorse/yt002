//
//  FSConfiguration.h
//  FashionShop
//
//  Created by gong yi on 11/13/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#include "FSConfiguration+Fonts.h"
#import "FSAppDelegate.h"

#ifndef FashionShop_FSConfiguration_h
#define FashionShop_FSConfiguration_h

#define REST_API_CLIENT_VERSION @"2.1.2"

//正式库
//#define REST_API_URL   @"http://itoo.yintai.com/api"
//#define REST_API_URL_OUT @"http://api.youhuiin.com"
//#define REST_API_APP_SECRET_KEY @"yintai123456"

//预生产库
#define REST_API_URL   @"http://apis.youhuiin.com/api"
#define REST_API_URL_OUT @"http://stage.youhuiin.com"
#define REST_API_APP_SECRET_KEY @"yintai123456"

/*
 预生产环境的地址切换了，原有的地址失效，使用新的地址：
 api的访问域： apis.youhuiin.com
 后台管理的访问域: apis.youhuiin.com:8080
 原有的itoo.yintai.com:7050,7070都无法访问了。
 */

//测试环境 http://stage.youhuiin.com
//生产环境 http://api.youhuiin.com
//其他 http://intime-env-hvrevspudb.elasticbeanstalk.com

//新浪微博
#define SINA_WEIBO_APP_KEY @"2978041275"
#define SINA_WEIBO_APP_SECRET_KEY @"ea68b2a26ca930c6b51d434decdd2c9b"
#define SINA_WEIBO_APP_REDIRECT_URI @"http://www.intime.com.cn"

//腾讯微博
#define QQ_WEIBO_APP_KEY @"801302732"
#define QQ_WEIBO_APP_SECRET_KEY @"cd497771f88f6971ad11855088d050fd"
#define QQ_WEIBO_APP_REDIRECT_URI @"http://www.intime.com.cn"

//微信
#define WEIXIN_API_APP_KEY @"wx413d6a12d10df434"

//QQ联合登陆
#define QQ_CONNECT_APP_ID @"100382932"
#define QQ_CONNECT_APP_KEY @"8acc22a900a6cf3a144c4e7364dafa78"

#define FLURRY_APP_KEY @"BVP8QWHDDXKCBPZRPFT4"

#define BAIDU_MAP_KEY @"D768745A12D429DEC85D896036A25C50A52313E6"

//notification
#define LN_USER_UPDATED @"LN_USER_UPDATED"
#define LN_FAVOR_UPDATED @"LN_USER_FAVOR_UPDATED"
#define LN_ITEM_UPDATED @"LN_USER_ITEM_UPDATED"
#define COMMON_PAGE_SIZE 20

#define CollectionView_Default_Height 100.0f

#define NAV_HIGH        44
#define TAB_HIGH        49
#define APP_HIGH        [[UIScreen mainScreen] applicationFrame].size.height
#define APP_WIDTH       [[UIScreen mainScreen] applicationFrame].size.width
#define SCREEN_HIGH     [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define MAIN_HIGH       APP_HIGH - NAV_HIGH
#define BODY_HIGH       APP_HIGH - NAV_HIGH - TAB_HIGH
#define theApp          ((FSAppDelegate *) [[UIApplication sharedApplication] delegate])
#define STATUSBAR_HIGH  ([UIApplication sharedApplication].statusBarHidden?0:20)
//当前设备是否支持高清
#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.width == 640 || [[UIScreen mainScreen] currentMode].size.width == 1536) : NO)
//是否高清，放大系数
#define RetinaFactor (isRetina?2:1)
// 是否iPad
#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kRecorderDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]  stringByAppendingPathComponent:@"Audios"]

#define RGBACOLOR(r,g,b,a)       [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGBCOLOR(r,g,b)          [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define XRGBCOLOR(r,g,b)         [UIColor colorWithRed:(0x##r)/255.0 green:(0x##g)/255.0 blue:(0x##b)/255.0 alpha:1]

#define FONT(a)             [UIFont systemFontOfSize:a]
#define BFONT(a)            [UIFont boldSystemFontOfSize:a]

#endif


typedef enum {
    SortByUnUsed = 0,//未使用
    SortByUsed,//已使用
    SortByDisable//无效
}FSGiftSortBy;

typedef enum {
    SortByNone = -1,
    SortByDistance = 0,
    SortByDate = 1,
    SortByPre = 2
}FSProSortBy;

typedef enum {
    SkipTypeDefault = 0,
    SkipTypeProductList,
    SkipTypePromotionDetail,
    SkipTypeProductDetail,
    SkipTypeNone,
    SkipTypeURL,
    /*
     SkipTypeDefault = 0;默认跳转商品列表，兼容老版本数据
     a、SkipTypeProductList=1：专题商品列表
     b、SkipTypePromotionDetail=2：活动详情
     c、SkipTypeProductDetail=3：商品详情
     d、SkipTypeNone=4：不跳转，即不能点击，主要做展示使用。
     e、SkipTypeURL=5：根据给定的URL，连接到特定的Web页面。
     */
}FSSkipType;