//
//  WxPayOrder.h
//  FashionShop
//
//  Created by HeQingshan on 13-10-17.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "WXApi.h"

@interface WxPayOrder : NSObject<ASIHTTPRequestDelegate,WXApiDelegate,UIAlertViewDelegate>

//商品唯一 id;字段来源:商户需要定义并维护自己的 商品 id,这个 id 与一张订单等价,微信后台凭借该 id 通过 Post 商户后台获取交易必须信息 。由商户生成后传入 。取值范围:32 字符以下
@property(nonatomic, strong) NSString * productid;

/*
 //公众号 id;字段来源:商户注册具有支付权限的公众 号成功后即可获得;传入方式:由商户直接传入。
 @property(nonatomic, copy) NSString *appid;
 
//公众号支付请求中用于加密的密钥 Key,可验证商户唯一身份,PaySignKey 对应于支付场景中的 appKey 值。
@property(nonatomic, copy) NSString * appkey;

//签名;字段来源:对前面的其他字段与 appKey 按照 字典序排序后,使用 SHA1 算法得到的结果。由商户生成后传入。
@property(nonatomic, copy) NSString * sign;
 */

-(BOOL)payOrder;

@end
