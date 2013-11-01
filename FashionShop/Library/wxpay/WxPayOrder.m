//
//  WxPayOrder.m
//  FashionShop
//
//  Created by HeQingshan on 13-10-17.
//  Copyright (c) 2013年 Fashion. All rights reserved.
//

#import "WxPayOrder.h"
#import "ASIHTTPRequest.h"
#import "NSString+Extention.h"
#import "FSWXConfig.h"

@implementation WxPayOrder

-(BOOL)payOrder
{
    if ([NSString isNilOrEmpty:self.productid]) {
        return NO;
    }
    [WXApi registerApp:WEIXIN_API_APP_KEY];
    if ([WXApi isWXAppInstalled]) {
        if (0) {//[[WXApi getApiVersion] intValue] < 5
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您的微信版本不支持微信支付，请现在最新版本！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            return NO;
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您没有安装微信，现在去安装" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        return NO;
    }
    
   // [WXApi openWXApp];
    NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    NSString *noncestr = [[NSString randomString] lowercaseString];
    NSString *changeOrderNumber = [self changeOrderNumber:self.productid];
    
    NSMutableString *mutStr = [NSMutableString stringWithFormat:@"appid=%@&", WXAppId];
    [mutStr appendFormat:@"appkey=%@&", WXPaySignKey];
    [mutStr appendFormat:@"noncestr=%@&", noncestr];
    [mutStr appendFormat:@"roductid=%@&", changeOrderNumber];
    [mutStr appendFormat:@"timestamp=%@", timestamp];
    NSString *signString = [NSString sha1:[mutStr lowercaseString]];
    
    NSString *path = [NSString stringWithFormat:@"weixin://wxpay/bizpayurl?sign=%@&appid=%@&productid=%@&timestamp=%@&noncestr=%@",signString,WXAppId,changeOrderNumber,timestamp,noncestr];
    
    /*
    NSURL *url = [NSURL URLWithString:path];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
     */
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
    
    return YES;
}

-(void) onRequestAppMessage
{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    
    [WXApi sendReq:req];
}

-(NSString *)changeOrderNumber:(NSString*)orderNum
{
    return [NSString stringWithFormat:@"1-%@", orderNum];
    
    /*
     微信支付的的productid有三种类型（app使用第一种，后两种H5使用）：
     组成方式为{类型}-{数据}。
     1. 订单号支付，类型为1， productid举例为1-11018200000
     2. sku号支付，类型为2，类型-skuid-storeid-sectionid
     3. product号支付，类型为3， 类型inventoryid-storeid-sectionid
     */
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"responseString:%@", responseString);

    // Use when fetching binary data
    NSData *responseData = [request responseData];
    NSLog(@"responseData:%@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"error:%@", error.description);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
    }
}

@end
